pragma solidity =0.5.16;

import './interfaces/ICapswapV2Factory.sol';
import './CapswapV2Pair.sol';

contract CapswapV2Factory is ICapswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    bytes32 public initCodeHash;

    uint private feeToNumerator;
    uint private feeToDenominator;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
        initCodeHash = keccak256(type(CapswapV2Pair).creationCode);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'CapswapV2: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'CapswapV2: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'CapswapV2: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(CapswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        ICapswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function feeToRate() external view returns (uint numerator,uint denominator){
        numerator = feeToNumerator;
        denominator = feeToDenominator;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'CapswapV2: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'CapswapV2: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setFeeToRate(uint numerator,uint denominator) external{
        require(msg.sender == feeToSetter, 'CapswapV2: FORBIDDEN');
        require(denominator >= numerator);
        feeToNumerator = numerator;
        feeToDenominator = denominator;
    }
}
