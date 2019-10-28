pragma solidity 0.5.11;

interface ERC20 {}

interface Kyber {
    function getOutputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns (uint256);
    function getInputAmount(ERC20 from, ERC20 to, uint256 amount) external view returns (uint256);
}

interface Synthetix {
    function getOutputAmount(bytes32 from, bytes32 to, uint256 amount) external view returns (uint256);
    function getInputAmount(bytes32 from, bytes32 to, uint256 amount) external view returns (uint256);
}

interface Uniswap {
    function getEthToTokenInputPrice(uint256 ethSold) external view returns(uint256);
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns(uint256);
    function getTokenToEthInputPrice(uint256 tokensSold) external view returns(uint256);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns(uint256);
}

contract BridgeOracle {
    ERC20 ethToken = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    Kyber kyber = Kyber(0xFd9304Db24009694c680885e6aa0166C639727D6); // Kyber oracle
    Synthetix synthetix = Synthetix(0xE86C848De6e4457720A1eb7f37B519010CD26d35); // Synthetix oracle
    Uniswap uniswap = Uniswap(0xe9Cf7887b93150D4F2Da7dFc6D502B216438F244); // Uniswap sETH pool
    
    function getEthToSynthOutputAmount(bytes32 synth, uint256 inputAmount) external view returns(uint256) {
        uint256 sethAmount = uniswap.getEthToTokenInputPrice(inputAmount);
        uint256 outputAmount = synthetix.getOutputAmount('sETH', synth, sethAmount);
        return outputAmount;
    }
    
    function getEthToSynthInputAmount(bytes32 synth, uint256 outputAmount) external view returns(uint256) {
        uint256 sethAmount = synthetix.getInputAmount('sETH', synth, outputAmount);
        uint256 inputAmount = uniswap.getEthToTokenOutputPrice(sethAmount);
        return inputAmount;
    }
    
    function getSynthToEthOutputAmount(bytes32 synth, uint256 inputAmount) external view returns(uint256) {
        uint256 sethAmount = synthetix.getOutputAmount(synth, 'sETH', inputAmount);
        uint outputAmount = uniswap.getTokenToEthInputPrice(sethAmount);
        return outputAmount;
    }
    
    function getSynthToEthInputAmount(bytes32 synth, uint256 outputAmount) external view returns(uint256) {
        uint256 sethAmount = uniswap.getTokenToEthOutputPrice(outputAmount);
        uint256 inputAmount = synthetix.getInputAmount(synth, 'sETH', sethAmount);
        return inputAmount;
    }
    
    function getTokenToSynthOutputAmount(ERC20 token, bytes32 synth, uint256 inputAmount) external view returns(uint256) {
        uint256 ethAmount = kyber.getOutputAmount(token, ethToken, inputAmount);
        uint256 sethAmount = uniswap.getEthToTokenInputPrice(ethAmount);
        uint256 outputAmount = synthetix.getOutputAmount('sETH', synth, sethAmount);
        return outputAmount;
    }
    
    function getTokenToSynthInputAmount(ERC20 token, bytes32 synth, uint256 outputAmount) external view returns(uint256) {
        uint256 sethAmount = synthetix.getInputAmount('sETH', synth, outputAmount);
        uint256 ethAmount = uniswap.getEthToTokenOutputPrice(sethAmount);
        uint256 inputAmount = kyber.getInputAmount(token, ethToken, ethAmount);
        return inputAmount;
    }
    
    function getSynthToTokenOutputAmount(bytes32 synth, ERC20 token, uint256 inputAmount) external view returns(uint256) {
        uint256 sethAmount = synthetix.getOutputAmount(synth, 'sETH', inputAmount);
        uint256 ethAmount = uniswap.getTokenToEthInputPrice(sethAmount);
        uint256 outputAmount = kyber.getOutputAmount(ethToken, token, ethAmount);
        return outputAmount;
    }
    
    function getSynthToTokenInputAmount(bytes32 synth, ERC20 token, uint256 outputAmount) external view returns(uint256) {
        uint256 ethAmount = kyber.getInputAmount(ethToken, token, outputAmount);
        uint256 sethAmount = uniswap.getTokenToEthOutputPrice(ethAmount);
        uint256 inputAmount = synthetix.getInputAmount(synth, 'sETH', sethAmount);
        return inputAmount;
    }
}
