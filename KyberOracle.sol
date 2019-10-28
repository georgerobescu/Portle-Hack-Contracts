pragma solidity ^0.5.11;

interface IERC20Token {
	function decimals() external pure returns (uint8);
}

interface KyberProxy {
	function getExpectedRate(IERC20Token _from, IERC20Token _to, uint256 _amount) external view returns(uint256, uint256);
}

contract KyberOracle {
	KyberProxy private proxy = KyberProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
	IERC20Token private etherToken = IERC20Token(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

	function getOutputAmount(IERC20Token _from, IERC20Token _to, uint256 _amount) public view returns (uint256) {
		(uint256 expectedRate, ) = proxy.getExpectedRate(_from, _to, _amount);
		uint256 defaultMultiplier = getMultiplier(etherToken);
		uint256 fromMultiplier = getMultiplier(_from);
		uint256 toMultiplier = getMultiplier(_to);
		uint256 amount = (expectedRate * toMultiplier * _amount) / (defaultMultiplier * fromMultiplier);
		return amount;
	}

	function getInputAmount(IERC20Token _from, IERC20Token _to, uint256 _amount) public view returns (uint256) {
		uint256 initialAmount = getMultiplier(_from);
		uint256 initialReturn = getOutputAmount(_from, _to, initialAmount);
		if (initialReturn == 0) {
			return 0;
		}
		uint256 initialCost = _amount * initialAmount / initialReturn;
		uint256 finalReturn = getOutputAmount(_from, _to, initialCost);
		if (finalReturn == 0) {
			return 0;
		}
		return _amount * initialCost / finalReturn;
	}
	
	function getMultiplier(IERC20Token _token) private view returns(uint256) {
		return 10 ** getDecimals(_token);
	}
	
	function getDecimals(IERC20Token _token) private view returns(uint256) {
		if (_token == etherToken) {
			return 18;
		}
		return _token.decimals();
	}
}
