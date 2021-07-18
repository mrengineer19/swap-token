pragma solidity >=0.4.22 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

interface IUniswap {
  function swapExactTokensForETH(
    uint amountIn, 
    uint amountOutMin, 
    address[] calldata path, 
    address to, 
    uint deadline)
    external
    returns (uint[] memory amounts);
  function WETH() external pure returns (address);
}

contract Swap {
  mapping(address => uint) public ethBalance;

  event Swapped(uint256 amount, address to);

  IUniswap uniswap;

  constructor() {
    uniswap = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
  }

  function swapTokensForEth(address token, uint amountIn, uint amountOutMin) payable external returns (bool) {
    address[] memory path = new address[](2);
    path[0] = token;
    path[1] = uniswap.WETH();
    require(IERC20(token).approve(address(uniswap), amountIn), 'Approve failed');
    uniswap.swapExactTokensForETH(
      amountIn, 
      amountOutMin, 
      path, 
      address(this), 
      block.timestamp + 100000
    );

    ethBalance[msg.sender] += amountOutMin;

    emit Swapped(ethBalance[msg.sender], msg.sender);

    return true;
  }

  function withdrawEth() public {
    require(ethBalance[msg.sender] > 0, 'You do not have eth to withdraw.');
    payable(msg.sender).transfer(ethBalance[msg.sender]);
    ethBalance[msg.sender] = 0;
  }

  function getEthBalance() public view returns (uint256) {
    return ethBalance[msg.sender];
  }

  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }

  receive() external payable {}
}