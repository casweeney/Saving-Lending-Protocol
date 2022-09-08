// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @author Casweeney Ojukwu
contract SavingLending is ERC20 {
    address owner;
    uint public constant maxTotalSupply = 10000000 * 10 ** 18;

    // runs immediately this contract is deployed: sets owner to msg.sender and mints token to contract address
    constructor() ERC20("Loan Token", "LTN") {
        owner = msg.sender;
        _mint(address(this), maxTotalSupply);
    }

    // mapping to track ETH savings and erc20 lendings
    mapping(address => uint) ethSavings;
    mapping(address => uint) erc20Lendings;

    // mapping to track ERC20 savings and ETH lending
    mapping(address => uint) erc20Savings;
    mapping(address => uint) ethLendings;

    /// @dev deposits ETH to the contract
    function depositEth() external payable {
        require(erc20Lendings[msg.sender] == 0, "you have an unresolved lending");
        require(msg.value > 0, "can't send zero eth");
        
        ethSavings[msg.sender] += msg.value;
    }

    /// @dev borrows ERC20 token to the caller
    function borrowErc20() external {
        require(ethSavings[msg.sender] > 0, "you can't borrow without collateral");
        require(erc20Lendings[msg.sender] == 0, "you have an unresolved lending transaction");
        require(address(this).balance >= ethSavings[msg.sender], "insufficient funds to lend, check later");

        uint lendingAmount = ethSavings[msg.sender];
        erc20Lendings[msg.sender] = lendingAmount;

        // perform transfer transaction below
        _transfer(address(this), msg.sender, lendingAmount);
    }

    /// @dev receives payback ERC20 borrowed from the contract
    function paybackErc20() external {
        require(erc20Lendings[msg.sender] > 0, "you can't payback without borrowing");
        uint borrowedAmount = erc20Lendings[msg.sender];
        require(balanceOf(msg.sender) >= borrowedAmount, "you don't have enough funds to pay back");

        _transfer(msg.sender, address(this), borrowedAmount);

        erc20Lendings[msg.sender] = 0;
    }

    /// @dev user gets back their ETH saved as collateral
    function getBackEth() external {
        require(erc20Lendings[msg.sender] == 0, "you have not paid back you borrowed funds");
        require(ethSavings[msg.sender] > 0, "you don't have saved Eth to withdraw");
        require(address(this).balance >= ethSavings[msg.sender], "no funds to payback, check later");

        uint ethSaved = ethSavings[msg.sender];
        ethSavings[msg.sender] = 0;

        payable(msg.sender).transfer(ethSaved);
    }

    // returns contract ETH balance
    function getContractBalance() external view returns (uint bal) {
        bal = address(this).balance;
    }

    // returns ETH savings of an address
    function getUserSaving(address _address) external view returns (uint addressBal) {
        addressBal = ethSavings[_address];
    }

    // returns amount of ERC20 token given to an address by the contract
    function getUserLending(address _address) external view returns (uint bal) {
        bal = erc20Lendings[_address];
    }
    
    /// @dev deposits ERC20 token as into contract
    function depositErc20(uint _amount) external {
        require(ethLendings[msg.sender] == 0, "you have an unresolved borrowed transaction");
        require(_amount > 0, "can't deposit zero token");

        erc20Savings[msg.sender] += _amount;
    }

    /// @dev borrow ETH from the contract
    function borrowEth() external {
        require(erc20Savings[msg.sender] > 0, "can't borrow without collateral");
        require(ethLendings[msg.sender] == 0, "you have an unresolved lending transaction");
        require(address(this).balance >= erc20Savings[msg.sender], "insufficient funds in contract, check later");

        ethLendings[msg.sender] = erc20Savings[msg.sender];

        payable(msg.sender).transfer(erc20Savings[msg.sender]);
    }


    /// @dev payback ETH borrowed from the contract
    function paybackEth() external payable {
        require(ethLendings[msg.sender] > 0, "you can't payback when you haven't borrowed");
        require(msg.value > 0, "can't send zero eth");
        require(msg.value > ethLendings[msg.sender], "you can't pay below what you borrowed");

        ethLendings[msg.sender] = 0;
    }

    /// @dev get back deposited ERC20 token
    function getBackErc20() external {
        require(ethLendings[msg.sender] == 0, "you can't get back funds without paying back loan");
        require(erc20Savings[msg.sender] > 0, "you don't have any save erc20 token");
        require(balanceOf(address(this)) >= erc20Savings[msg.sender], "insufficient funds, check back later");

        uint savedErc20 = erc20Savings[msg.sender];

        erc20Savings[msg.sender] = 0;
        _transfer(address(this), msg.sender, savedErc20);
    }
}