pragma solidity >=0.5.0;

interface ICapswapV2Callee {
    function capswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}
