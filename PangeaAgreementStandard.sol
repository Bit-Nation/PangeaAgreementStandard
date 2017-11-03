contract PangeaAgreementStandard {

mapping(address => uint) citizenNonces;

mapping(bytes32 => address) agreementRegistry;

// Attach a public key to the internetOfAgreements
function newCitizen() { 

    if(citizenNonces[msg.sender] != 0) throw; // Already attached to the IoA
    citizenNonces[msg.sender]++;

}

modifier isTransactionFee {

// Use this modifier to add a transaction fee in PAT for transacting with the IoA

_;
}

function newAgreement(
        bytes32 _data, 
        bytes32 _agreementID, 
        address[] _citizens,
        bytes32[] _agreementSignatures) 
    isTransactionFee
{

// Verify the agreement signatures, agreement ID as well as citizenship 
for(uint i = 0; i < _agreementSignatures.length, i++) {
if(!ecverify(
    _agreementID, 
    _agreementSignatures[i], 
    _citizens[i])) 
throw;
}

uint nonce; 

for(uint i = 0; i < _citizens.length, i++) { 
    uint citizenNonce = citizenNonces[_citizens[i]]; 
    if(citizenNonce == 0) throw; // Agreements are only between citizen 
    nonce += citizenNonce; 
}

bytes32 agreementID = sha3(_citizens[], nonce, _data);

if(agreementID != _agreementID) throw; 

// and increment citizen nonces 

for(uint i = 0; i < _citizens.length; i++) { 
    address citizen = _citizens[i]; 
    citizenNonces[citizen] += 1; 
}

// Write the agreement contract to the state

    address agreementContract;
    uint s = _data.length;

    assembly {
        calldatacopy(mload(0x40), 68, s)
        agreementContract:= create(callvalue, mload(0x40), s)
    }

    agreementRegistry[_agreementID] = agreementContract;

}
