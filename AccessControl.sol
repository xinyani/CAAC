// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "./Management.sol";
import "./Judge.sol";


contract AccessControl {
    
    Management manager;
    Judge judge;

    struct Requester {
        // 0 is initial value, -1 is not requested, 1
        bool isRequested;
        // time of last request
        uint256 ToLR;
    }

        //时间工具
    uint constant internal SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant internal SECONDS_PER_HOUR = 60 * 60;
    uint constant internal SECONDS_PER_MINUTE = 60;
    uint constant internal OFFSET19700101 = 2440588;
    //每月天数
    uint8[] monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];


    mapping(string => int) private rightTable;

    mapping(string => bool) private blackListIpMap;

    // store ToLR using map: key is addr, value is ToLRMap
    //用于保存具有映射关系的数据，Map集合里保存着两组值（键和值），一组用于保存Map的key，另一组保存着Map的value。
    //键值对映射关系一个键对应一个值, 键不能重复，值可以重复,元素存取无序
    mapping(address => Requester) private requestMap;

    event AccessControlRet(address from, address to, string action, string result, uint256 accessTime);

    // MC is management contract, JC is judge contract
    function init(address _MCAddr, address _JCAddr) public {
        manager = Management(_MCAddr);
        judge = Judge(_JCAddr);

        // assign right degree, higher number equals higher right.      TODO: add not found right
        //分配正确的权利，数字越高，权利越高,可以添加没有发现的权利
        rightTable["read"] = 1;
        rightTable["write"] = 2;
        rightTable["delete"] = 3;
        blackListIpMap['2.2.2.2'] = true;
    }

    // 检查请求者是否已请求，阻止频繁访问的用户
    function checkRequesterStatus() private {
        if(requestMap[msg.sender].isRequested == true) {
            uint256 timeGap = block.timestamp - requestMap[msg.sender].ToLR;
            requestMap[msg.sender].ToLR = block.timestamp;
            // 请求时间间隔为6秒
            if(timeGap <= 6) {
                // 给予非法用户惩罚：阻止10秒
                judge.setBlackList(msg.sender);
            }
        } else {
            requestMap[msg.sender].isRequested = true;
            requestMap[msg.sender].ToLR = block.timestamp;
        }
    }
    /*
        core function.
    */
    function accessControl(address _objectAddr, string memory action) public returns (bool res) {
        // 检查请求者是否已请求
        checkRequesterStatus();

        uint curTime = getCurTime();
        bool isBlocked;
        uint256 ToLB;
        (ToLB, isBlocked) = judge.getBLUByAddr(msg.sender);
        // check if requester is blocked
        if(isBlocked && curTime <= ToLB) {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Still blocked, unable to access!", block.timestamp);

            res = false;
            return res;
        } else {
            // legal user should be unblocked
            judge.unblockUser(msg.sender);
        }

        string memory right = manager.getRight(msg.sender, _objectAddr);
        bool _isLegalAction = isLegalAction(action);
        if(_isLegalAction) {
            // check if the subject's action over authorization
            if(rightTable[action] > rightTable[right]) {
                emit AccessControlRet(msg.sender, _objectAddr, action, "Unauthorized access!", block.timestamp);
                res = false;
                return res;
            }
        } else {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Illegal action!", block.timestamp);
            res = false;
            return false;
        }

        string memory subjName;
        string memory subjIP;
        (subjName, subjIP) = manager.getSubjInfo(msg.sender);
        // check subject's ip
        if(blackListIpMap[subjIP]) {
            emit AccessControlRet(msg.sender, _objectAddr, action, "Illegal IP address!", block.timestamp);
            res = false;
            return res;
        }
        // legal user will pass
        emit AccessControlRet(msg.sender, _objectAddr, action, "Access pass!", block.timestamp);
        res = true;
        return res;
    }
    
    function getCurTime() public view returns(uint256) {
        return block.timestamp;
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


    function isLegalAction(string memory _action) public view returns(bool res) {
        return !(rightTable[_action] == 0);
    }

    // function getTimeOfLastRequest(address _sender) public view returns (uint256 time) {
    //     time = requestMap[_sender];
    // }

}