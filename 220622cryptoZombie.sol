// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.10;

contract RSP {
    constructor () payable {} 
    enum Hand { //가위/바위/보 값에 대한 enum 0,1,2
        rock, paper, scissors
        }

    enum PlayerStatus {
        STATUS_WIN, STATUS_LOSE, STATUS_TIE, STATUS_PENDING
    }

    struct Player {
        address payable addr; //주소
        uint256 playerBetAmount; //배팅금액
        Hand hand; //플레이어가 낸 가위/바위/보 값
        PlayerStatus playerStatus;
    }

    enum GameStatus {
        STATUS_NOT_STARTED, STATUS_STARTED, STATUS_COMPLETE, STATUS_ERRROR
    }

    struct Game {
        Player originator; //방장정보
        Player taker; //참여자 정보
        uint256 betAmount; //총 베팅금액
        GameStatus gameStatus; //게임의 현 상태
    }

    mapping(uint => Game) rooms; //지정해놓은 동적배열이다. rooms[0], rooms[1]형식으로 접근할 수 있으며, 각 요소는 Game구조체 형식
    uint roomLen = 0; //room의 키 값. 방이 생성될때마다 1씩 올라감

    modifier isValidHand (Hand _hand) {
        require((_hand == Hand.rock) || (_hand == Hand.paper) || (_hand == Hand.scissors));
        _; //3가지가 아닐경우 취소됨
    }

    function createRoom (Hand _hand) public payable isValidHand(_hand) returns (uint roomNum) {//몇번방을 리턴
        rooms[roomLen] = Game ({
            betAmount: msg.value,
            gameStatus: GameStatus.STATUS_NOT_STARTED, //초기화
            originator: Player({
                hand: _hand,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: msg.value
            }),
            taker: Player({
                hand: Hand.rock,
                addr: payable(msg.sender),
                playerStatus: PlayerStatus.STATUS_PENDING,
                playerBetAmount: 0
            })
        });
        roomNum = roomLen; //roomNum은 리턴된다.
        roomLen += 1;//다음방번호 설정
    }
    function joinRoom(uint roomNum, Hand _hand) public payable isValidHand(_hand) {
        rooms[roomNum].taker = Player({
            hand: _hand,
            addr: payable(msg.sender),
            playerStatus: PlayerStatus.STATUS_PENDING,
            playerBetAmount: msg.value
        });
        rooms[roomNum].betAmount = rooms[roomNum].betAmount + msg.value;
        compareHands(roomNum); //게임결과 업데이트 함수 호출
    }

    function compareHands(uint roomNum) private {
        uint8 originator = uint8(rooms[roomNum].originator.hand);
        uint8 taker = uint8(rooms[roomNum].taker.hand);

        rooms[roomNum].gameStatus = GameStatus.STATUS_STARTED;

        if (taker == originator) { //비긴경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_TIE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_TIE;
        }
        else if ((taker + 1) % 3 == originator) { //방장이 이긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_WIN;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_LOSE;
        }
        else if ((taker + 1) % 3 == taker) { //참가자가 이긴 경우
            rooms[roomNum].originator.playerStatus = PlayerStatus.STATUS_LOSE;
            rooms[roomNum].taker.playerStatus = PlayerStatus.STATUS_WIN;
        } else { //그 외이 상황에는 상태를 에러로 업데이트 한다.
            rooms[roomNum].gameStatus = GameStatus.STATUS_ERRROR;
        }
    }
    function payout(uint roomNum) public payable {
        if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_TIE && rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_TIE){
            rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
            rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
        } else {
            if (rooms[roomNum].originator.playerStatus == PlayerStatus.STATUS_WIN){
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].betAmount);
            }else if (rooms[roomNum].taker.playerStatus == PlayerStatus.STATUS_WIN) {
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].betAmount);
            }else { 
                rooms[roomNum].originator.addr.transfer(rooms[roomNum].originator.playerBetAmount);
                rooms[roomNum].taker.addr.transfer(rooms[roomNum].taker.playerBetAmount);
        }
    }
    rooms[roomNum].gameStatus = GameStatus.STATUS_COMPLETE; //게임이 종료되었으므로 게임 상태 변경 
}
}