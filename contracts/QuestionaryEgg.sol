pragma solidity 0.5.6;

contract QuestionaryEgg {
    string public name = "QuestionaryEgg";
    string public symbol = "QET";
    
   // string public name = "QUESTIONARYEGG"; string public symbol = "QET"; 
    mapping(uint256 => address) public tokenOwner; 
    mapping(uint256 => string)public tokenURIs;

    //소유한 토큰 리스트
    mapping(address => uint256[])private _ownedTokens;
    bytes4 private constant _KIP17_RECEIVED = 0x6745782b;

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public returns(bool) {
        tokenOwner[tokenId] = to;
        tokenURIs[tokenId] = tokenURI;

        _ownedTokens[to].push(tokenId); //어떤 토큰을 가지고 있는지 한눈에 확인하는 용도
        return true;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(from == msg.sender, "from != msg.sender");
        require(from == tokenOwner[tokenId], "you are not the owner of the token");
           // transferFrom(msg.sender, to, tokenId); //safeTransferFrom(address from, address to, uint256 tokenId)
            _removeTokenFromList(from, tokenId); //_removeTokenFromList(from, tokenId);
            _ownedTokens[to].push(tokenId); // _ownedTokens[to].push(tokenId);
            tokenOwner[tokenId] = to;

        require(_checkOnKIP17Received(from, to, tokenId, _data), "KIP17 : transfer to non KIP! &Receiver implementer");
    }

    function _checkOnKIP17Received(address from, address to, uint256 tokenId, bytes memory _data) internal returns (bool) {
        bool success;
        bytes memory returndata;

        if(!isContract(to)) {
            return true;
        }
        (success, returndata) = to.call(
            abi.encodeWithSelector(_KIP17_RECEIVED,
            msg.sender,
            from,
            tokenId,
            _data
            )
        );
        if (
            returndata.length != 0 &&
            abi.decode(returndata, (bytes4)) == _KIP17_RECEIVED
        ) {
            return true;
        }
        return false;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account)}
        return size > 0;
    }

     function _removeTokenFromList(address from, uint256 tokenId) private { 
        //[10, 18, 23, 16] 23식제
        //[10, 18, 16, 23]
        //[10, 18, 16]
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        for (uint256 i = 0; i < _ownedTokens[from].length; i++) {
            if(tokenId == _ownedTokens[from][i]) {
                _ownedTokens[from][i] = _ownedTokens[from][lastTokenIndex];
                _ownedTokens[from][lastTokenIndex] = tokenId;
                break;
            } //어떤 토큰을 전송했는지, 어떤 토큰이 남았는지 확인하는 용도
        }
        _ownedTokens[from].length--;
    }

    function ownedTokens(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
    function setTokenUri(uint256 id, string memory uri) public {
        tokenURIs[id] = uri;
    }
}

contract NFTMarket {
    mapping(uint256 => address) public seller;

    function buyNFT(uint256 tokenId, address NFTAddress) public payable returns (bool) {
        /*
        구매한 사람한테 0.01klay 전송
        seller(판매자)가 0.01klay를 받아야함
        payable을 붙여준 주소에만 코드상으로 클레이를 전송 가능
        */
        address payable receiver = address(uint256(seller[tokenId]));
        /*
        semd 0.01klay to receiver
        10 ** 18 QET = 1klay
        10 ** 16 QET = 0.01 klay
        */
        receiver.transfer(1 ** 16);
        //전송
        QuestionaryEgg(NFTAddress).safeTransferFrom(address(this), msg.sender, tokenId, "0x00"); 
       // Mynft(NFTAddress).saftTransferForm(address(this), to, tokenId);
        return true;
    }

    function onKIP17Received(address from, uint256 tokenId) public returns (bytes4) {
        seller[tokenId] = from;
        return bytes4(keccak256("onKIP17Received(address, address, uint256, bytes)" ));

    }

}









