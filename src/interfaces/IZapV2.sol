// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IZapV2 {
  struct ReserveData {
    uint256 rIn;
    uint256 rOut;
    uint256 vIn;
    uint256 vOut;
    uint256 feeInPrecision;
  }

  function zapInEth(
    IERC20 tokenOut,
    address pool,
    address to,
    uint256 minLpQty,
    uint256 deadline
  ) external payable returns (uint256 lpQty);

  function zapIn(
    IERC20 tokenIn,
    IERC20 tokenOut,
    uint256 userIn,
    address pool,
    address to,
    uint256 minLpQty,
    uint256 deadline
  ) external returns (uint256 lpQty);

  function zapOut(
    IERC20 tokenIn,
    IERC20 tokenOut,
    uint256 liquidity,
    address pool,
    address to,
    uint256 minTokenOut,
    uint256 deadline
  ) external returns (uint256 amountOut);

  function zapOutPermit(
    IERC20 tokenIn,
    IERC20 tokenOut,
    uint256 liquidity,
    address pool,
    address to,
    uint256 minTokenOut,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountOut);

  function zapOutEth(
    IERC20 tokenIn,
    uint256 liquidity,
    address pool,
    address to,
    uint256 minTokenOut,
    uint256 deadline
  ) external returns (uint256 amountOut);

  function zapOutEthPermit(
    IERC20 tokenIn,
    uint256 liquidity,
    address pool,
    address to,
    uint256 minTokenOut,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountOut);

  function calculateSwapAmounts(
    IERC20 tokenIn,
    IERC20 tokenOut,
    address pool,
    uint256 userIn
  ) external view returns (uint256 amountSwap, uint256 amountOutput);

  function calculateZapInAmounts(
    IERC20 tokenIn,
    IERC20 tokenOut,
    address pool,
    uint256 userIn
  ) external view returns (uint256 tokenInAmount, uint256 tokenOutAmount);

  function calculateZapOutAmount(
    IERC20 tokenIn,
    IERC20 tokenOut,
    address pool,
    uint256 lpQty
  ) external view returns (uint256);


}