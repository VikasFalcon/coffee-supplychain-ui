pragma solidity ^0.4.23;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainStorage is SupplyChainStorageOwnable {
    
    /* Events */
    event AuthorizedCaller(address _caller);
    event DeAuthorizedCaller(address _caller);
    
    /* Modifiers */
    
    modifier onlyAuthCaller(){
        require(authorizedCaller[msg.sender] == true);
        _;
    }
    
    
    /* User Related */
    struct user {
        string name;
        string contactNo;
        bool isActive;
    } 
    
    mapping(address => user) userDetails;
    mapping(address => string) userRole;
    
    /* Caller Mapping */
    mapping(address => bool) authorizedCaller;
    
    /*User Roles
        SUPER_ADMIN,
        FARM_INSPECTION,
        HARVESTER,
        EXPORTER,
        IMPORTER,
        PROCESSOR
    */
    
    /* Process Related */
     struct basicDetails {
        string registrationNo;
        string farmerName;
        string farmAddress;
        string exporterName;
        string importerName;
        
    }
    
    struct farmInspector {
        string coffeeFamily;
        string typeOfSeed;
        string fertilizerUsed;
    }
    
    struct harvester {
        string cropVariety;
        string tempatureUsed;
        string humidity;
    }    
    
    struct exporter {
        uint256 quantity;
        string destinationAddress;
        string shipName;
        string shipNo;
        uint256 departureDateTime;
        uint256 estimateDateTime;
        uint256 plantNo;
        uint256 exporterId;
    }
    
    struct importer {
        uint256 quantity;
        string shipName;
        string shipNo;
        uint256 arrivalDateTime;
        string transportInfo;
        string warehouseName;
        string warehouseAddress;
        uint256 importerId;
    }
    
    struct processor {
        uint256 quantity;
        string tempature;
        uint256 rostingDuration;
        string internalBatchNo;
        uint256 packageDateTime;
        string processorName;
        string processorAddress;
    }
    
    mapping (bytes32 => basicDetails) batchBasicDetails;
    mapping (bytes32 => farmInspector) batchFarmInspector;
    mapping (bytes32 => harvester) batchHarvester;
    mapping (bytes32 => exporter) batchExporter;
    mapping (bytes32 => importer) batchImporter;
    mapping (bytes32 => processor) batchProcessor;
    mapping (bytes32 => string) nextAction;
    
    /*Initialize struct pointer*/
    user userDetail;
    basicDetails basicDetailsData;
    farmInspector farmInspectorData;
    harvester harvesterData;
    exporter exporterData;
    importer importerData;
    processor processorData; 
    
    /* authorize caller */
    function authorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = true;
        emit AuthorizedCaller(_caller);
        return true;
    }
    
    /* deauthorize caller */
    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) 
    {
        authorizedCaller[_caller] = false;
        emit DeAuthorizedCaller(_caller);
        return true;
    }
    
    
    
    /* Get User Role */
    function getUserRole(address _userAddress) public onlyAuthCaller view returns(string)
    {
        return userRole[_userAddress];
    }
    
    /* Get Next Action  */    
    function getNextAction(bytes32 _batchNo) public onlyAuthCaller view returns(string)
    {
        return nextAction[_batchNo];
    }
        
    /*set user details*/
    function setUser(address _userAddress,
                     string _name, 
                     string _contactNo, 
                     string _role, 
                     bool _isActive) public onlyAuthCaller returns(bool){
        
        /*store data into struct*/
        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        
        /*store data into mapping*/
        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;
        
        return true;
    }  
    
    /*get user details*/
    function getUser(address _userAddress) public onlyAuthCaller view returns(string name, 
                                                                string contactNo, 
                                                                bool isActive, 
                                                                string role){

        /*Getting value from struct*/
        user memory tmpData = userDetails[_userAddress];
        
        return (tmpData.name, tmpData.contactNo, tmpData.isActive, userRole[_userAddress]);
    }
    
    /*get batch basicDetails*/
    function getBasicDetails(bytes32 _batchNo) public onlyAuthCaller view returns(string registrationNo,
                             string farmerName,
                             string farmAddress,
                             string exporterName,
                             string importerName) {
        
        basicDetails memory tmpData = batchBasicDetails[_batchNo];
        
        return (tmpData.registrationNo,tmpData.farmerName,tmpData.farmAddress,tmpData.exporterName,tmpData.importerName);
    }
    
    /*set batch basicDetails*/
    function setBasicDetails(string _registrationNo,
                             string _farmerName,
                             string _farmAddress,
                             string _exporterName,
                             string _importerName
                             
                            ) public onlyAuthCaller returns(bytes32) {
        
        bytes32 batchNo = keccak256(now);
        
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.farmerName = _farmerName;
        basicDetailsData.farmAddress = _farmAddress;
        basicDetailsData.exporterName = _exporterName;
        basicDetailsData.importerName = _importerName;
        
        batchBasicDetails[batchNo] = basicDetailsData;
        
        nextAction[batchNo] = 'FARM_INSPECTION';   
        
        
        return batchNo;
    }
    
    /*set farm Inspector data*/
    function setFarmInspectorData(bytes32 batchNo,
                                    string _coffeeFamily,
                                    string _typeOfSeed,
                                    string _fertilizerUsed) public onlyAuthCaller returns(bool){
        farmInspectorData.coffeeFamily = _coffeeFamily;
        farmInspectorData.typeOfSeed = _typeOfSeed;
        farmInspectorData.fertilizerUsed = _fertilizerUsed;
        
        batchFarmInspector[batchNo] = farmInspectorData;
        
        nextAction[batchNo] = 'HARVESTER'; 
        
        return true;
    }
    
    
    /*get farm inspactor data*/
    function getFarmInspectorData(bytes32 batchNo) public onlyAuthCaller view returns (string coffeeFamily,string typeOfSeed,string fertilizerUsed){
        
        farmInspector memory tmpData = batchFarmInspector[batchNo];
        return (tmpData.coffeeFamily, tmpData.typeOfSeed, tmpData.fertilizerUsed);
    }
    

    /*set Harvester data*/
    function setHarvesterData(bytes32 batchNo,
                              string _cropVariety,
                              string _tempatureUsed,
                              string _humidity) public onlyAuthCaller returns(bool){
        harvesterData.cropVariety = _cropVariety;
        harvesterData.tempatureUsed = _tempatureUsed;
        harvesterData.humidity = _humidity;
        
        batchHarvester[batchNo] = harvesterData;
        
        nextAction[batchNo] = 'EXPORTER'; 
        
        return true;
    }
    
    /*get farm Harvester data*/
    function getHarvesterData(bytes32 batchNo) public onlyAuthCaller view returns(string cropVariety,
                                                                                           string tempatureUsed,
                                                                                           string humidity){
        
        harvester memory tmpData = batchHarvester[batchNo];
        return (tmpData.cropVariety, tmpData.tempatureUsed, tmpData.humidity);
    }
    
    /*set Exporter data*/
    function setExporterData(bytes32 batchNo,
                              uint256 _quantity,    
                              string _destinationAddress,
                              string _shipName,
                              string _shipNo,
                              uint256 _estimateDateTime,
                              uint256 _plantNo,
                              uint256 _exporterId) public onlyAuthCaller returns(bool){
        
        exporterData.quantity = _quantity;
        exporterData.destinationAddress = _destinationAddress;
        exporterData.shipName = _shipName;
        exporterData.shipNo = _shipNo;
        exporterData.departureDateTime = now;
        exporterData.estimateDateTime = _estimateDateTime;
        exporterData.plantNo = _plantNo;
        exporterData.exporterId = _exporterId;
        
        batchExporter[batchNo] = exporterData;
        
        nextAction[batchNo] = 'IMPORTER'; 
        
        return true;
    }
    
    /*get Exporter data*/
    function getExporterData(bytes32 batchNo) public onlyAuthCaller view returns(uint256 quantity,
                                                                string destinationAddress,
                                                                string shipName,
                                                                string shipNo,
                                                                uint256 departureDateTime,
                                                                uint256 estimateDateTime,
                                                                uint256 plantNo,
                                                                uint256 exporterId){
        
        
        exporter memory tmpData = batchExporter[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.destinationAddress, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.departureDateTime, 
                tmpData.estimateDateTime, 
                tmpData.plantNo,
                tmpData.exporterId);
                
        
    }

    
    /*set Importer data*/
    function setImporterData(bytes32 batchNo,
                              uint256 _quantity, 
                              string _shipName,
                              string _shipNo,
                              string _transportInfo,
                              string _warehouseName,
                              string _warehouseAddress,
                              uint256 _importerId) public onlyAuthCaller returns(bool){
        
        importerData.quantity = _quantity;
        importerData.shipName = _shipName;
        importerData.shipNo = _shipNo;
        importerData.arrivalDateTime = now;
        importerData.transportInfo = _transportInfo;
        importerData.warehouseName = _warehouseName;
        importerData.warehouseAddress = _warehouseAddress;
        importerData.importerId = _importerId;
        
        batchImporter[batchNo] = importerData;
        
        nextAction[batchNo] = 'PROCESSOR'; 
        
        return true;
    }
    
    /*get Importer data*/
    function getImporterData(bytes32 batchNo) public onlyAuthCaller view returns(uint256 quantity,
                                                                                        string shipName,
                                                                                        string shipNo,
                                                                                        uint256 arrivalDateTime,
                                                                                        string transportInfo,
                                                                                        string warehouseName,
                                                                                        string warehouseAddress,
                                                                                        uint256 importerId){
        
        importer memory tmpData = batchImporter[batchNo];
        
        
        return (tmpData.quantity, 
                tmpData.shipName, 
                tmpData.shipNo, 
                tmpData.arrivalDateTime, 
                tmpData.transportInfo,
                tmpData.warehouseName,
                tmpData.warehouseAddress,
                tmpData.importerId);
                
        
    }

    /*set Proccessor data*/
    function setProcessorData(bytes32 batchNo,
                              uint256 _quantity, 
                              string _tempature,
                              uint256 _rostingDuration,
                              string _internalBatchNo,
                              uint256 _packageDateTime,
                              string _processorName,
                              string _processorAddress) public onlyAuthCaller returns(bool){
        
        
        processorData.quantity = _quantity;
        processorData.tempature = _tempature;
        processorData.rostingDuration = _rostingDuration;
        processorData.internalBatchNo = _internalBatchNo;
        processorData.packageDateTime = _packageDateTime;
        processorData.processorName = _processorName;
        processorData.processorAddress = _processorAddress;
        
        batchProcessor[batchNo] = processorData;
        
        return true;
    }
    
    
    /*get Proccessor data*/
    function getProccesorData( bytes32 batchNo) public onlyAuthCaller view returns(
                                                                                        uint256 quantity,
                                                                                        string tempature,
                                                                                        uint256 rostingDuration,
                                                                                        string internalBatchNo,
                                                                                        uint256 packageDateTime,
                                                                                        string processorName,
                                                                                        string processorAddress){

        processor memory tmpData = batchProcessor[batchNo];
        
        
        return (
                tmpData.quantity, 
                tmpData.tempature, 
                tmpData.rostingDuration, 
                tmpData.internalBatchNo,
                tmpData.packageDateTime,
                tmpData.processorName,
                tmpData.processorAddress);
                
        
    }
  
}    