// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Management {

    struct DatasetInfo {        //数据发送者
        address datasetAddr;//数据上传者地址
        string datasetName; //数据名称
        string datasetType;//数据类别
        string status; //数据状态

    
    }

    struct SubjInfo {       //数据请求者
        address subjectAddr;
        string subjectName;
        // store the access right of subj to obj
        mapping(address => string) rightTable; 
        string ipAddr;
        
    }

    // store data info using map
    mapping(address => DatasetInfo) private datasetInfoMap;

    mapping(address => SubjInfo) public subjInfoMap;

    mapping (address=>string) public stringIpfs;  //新增

    function setDatasetInfo(address _datasetAddr, string memory _datasetName, string memory _datasetType, string memory _status) public {
        datasetInfoMap[_datasetAddr].datasetAddr = _datasetAddr;
        datasetInfoMap[_datasetAddr].datasetName = _datasetName;
        datasetInfoMap[_datasetAddr].datasetType = _datasetType;
        datasetInfoMap[_datasetAddr].status = _status;

    }

    function setSubjInfo(string memory _subjectName, string memory _ipAddr) public {
        address _subjectAddr = msg.sender;
        subjInfoMap[_subjectAddr].subjectAddr = _subjectAddr;
        subjInfoMap[_subjectAddr].subjectName = _subjectName;
        subjInfoMap[_subjectAddr].ipAddr = _ipAddr;
    }

    // save as string 
    function saveString(string memory ipfs) public {
        stringIpfs[msg.sender] = ipfs;
    }

    // subject register for their right 主体注册他们的权利：主体是合约部署者
    function registerRight(address _subjectAddr, string memory Right, address _objectAddr, string memory right) public {
        // datatype consisting nested mapping(s) must be declared in storage!!!必须在存储中声明由嵌套映射组成的数据类型！！！
        subjInfoMap[msg.sender].rightTable[_subjectAddr] = Right;
        subjInfoMap[_subjectAddr].rightTable[_objectAddr] = right;

    }
 
    function getDatasetInfoByAddr(address _addr) public view returns (DatasetInfo memory) {
        return datasetInfoMap[_addr];
    }

    function getRight(address _subjectAddr, address _objectAddr) public view returns (string memory) {
        return subjInfoMap[_subjectAddr].rightTable[_objectAddr];//客体是其他访问机构
    }

    function getSubjInfo(address _subjectAddr) public view returns (string memory subjName, string memory ipAddr) {
        subjName = subjInfoMap[_subjectAddr].subjectName;
        ipAddr = subjInfoMap[_subjectAddr].ipAddr;
    }

    // // hard-code for test
    // function init() public {
    //     // dataset info
    //     address dataset1;
    //     address dataset2;
    //     address dataset3;
    //     address dataset4;
    //     (dataset1, dataset2, dataset3,dataset4) = (0xb4d18d483b641200Aa096558C9bA63aeb243002b, 
    //     0xfF5d2fe96548E05E49C67FcC36C7dBecA2f501f2, 0xbE7186f383961Cc24Ad8012A2F2942667a72788F,0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db);
    //     setDatasetInfo(dataset1, "OPT_FP_SOBT", "FP", "202008301010"); //计划离港时间，12位时间格式202008301010，精确到分，航班计划数据,
    //     setDatasetInfo(dataset2, "OPT_FL_DepOnTime", "FL", "1");//离港正常，航班标签数据，计划取消状态：1个字符{1,0}，
    //     setDatasetInfo(dataset3, "OPT_FS_AOBT", "FS", "202008301010");//实际离港时间,航班动态数据，12位时间格式202008301010，精确到分，
    //     setDatasetInfo(dataset4, "OPT_FGS_StartFuelTime", "FGS", "202008301011");//供油开始时间，12位时间格式202008301010，精确到分，航班地面保障数据，
    // }

}