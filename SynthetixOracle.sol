pragma solidity 0.5.11;

interface Synthetix {
    function effectiveValue(bytes32 from, uint256 amount, bytes32 to) external view returns (uint256);
}

contract SynthetixOracle {
    Synthetix synthetix = Synthetix(0x99a46c42689720d9118FF7aF7ce80C2a92fC4f97);
    
    function getOutputAmount(bytes32 from, bytes32 to, uint256 amount) external view returns (uint256) {
        uint256 value = synthetix.effectiveValue(from, amount, to);
        return value * 995 / 1000;
    }
    
    function getInputAmount(bytes32 from, bytes32 to, uint256 amount) external view returns (uint256) {
        uint256 value = synthetix.effectiveValue(to, amount, from);
        return value * 1000 / 995;
    }
}
