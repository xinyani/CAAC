// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Judge {

    struct BlackListUser {
        address addr;
        // 0 is normal, 1 is illegral IP, 2 is request too much, 3 is unauthorized
        uint status;

        // time of last block
        uint256 ToLB;
        //if a user is blocked => true
        bool blocked;
    }
    //时间工具
    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
    //每月天数
    uint8[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];



    // if the user is blocked, blackList[user] == true
    mapping(address => BlackListUser) private blackList;

    // log blocked user's info
    event BlockUserInfo(address blockedUser, uint256 ToLB);

    function setBlackList(address _userAddr) public {
        blackList[_userAddr].addr = _userAddr;//黑名单：0x583031D1113aD414F02576BD6afaBfb302140225
        //block for 10 seconds
        blackList[_userAddr].ToLB = block.timestamp + 10;
        blackList[_userAddr].blocked = true;

        emit BlockUserInfo(_userAddr, blackList[_userAddr].ToLB);
    }

    function unblockUser(address _userAddr) public {
        blackList[_userAddr].blocked = false; //合法用户：0xdD870fA1b7C4700F2BD7f44238821C26f7392148
    }

    // BLU is black list user
    function getBLUByAddr(address _userAddr) public view returns (uint256 _ToLB, bool _blocked) {
        _ToLB = blackList[_userAddr].ToLB;
        _blocked = blackList[_userAddr].blocked;
    }

    function getCurTime() public view returns (uint256 curTime) {
        curTime = block.timestamp; //当前区块产生时间
    }
    //时间戳转日期（新增）
    function daysToDate(int timestamp, int8 timezone) public pure returns (uint year, uint month, uint day, uint hour, uint minute){
        return _daysToDate(timestamp + timezone * int(SECONDS_PER_HOUR));
    }
    //时间戳转日期，UTC时区
    function _daysToDate(int timestamp) private pure returns (uint year, uint month, uint day, uint hour, uint minute) {
        uint _days = uint(timestamp) / SECONDS_PER_DAY;
 
        uint L = _days + 68569 + OFFSET19700101;
        uint N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * year / 4 + 31;
        month = 80 * L / 2447;
        day = L - 2447 * month / 80;
        L = month / 11;
        month = month + 2 - 12 * L;
        year = 100 * (N - 49) + year + L;
        hour = uint(((timestamp ) / 3600) % 24); // 求出小时数，记得模上24
        minute = uint(((timestamp) / 60) % 60); // 求出分钟数，记得模上60
    }
}