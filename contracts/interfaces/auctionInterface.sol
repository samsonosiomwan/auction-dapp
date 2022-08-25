//SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;



interface IAuction{
  

  

    function cancelAuction() external;

    function placeBid() external payable;

    function finalizeAuction() external;
}