// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract BGT is ERC20, Ownable {

    uint256 _totalBridgtSupply;

    mapping(address => bool) private _bridgeAdmins;
    mapping(address => bool) private _policemans;

    mapping(address => bool) private _prohibitFrom;
    mapping(address => bool) private _prohibitTo;


    constructor() ERC20("BG Trade", "BGT") {
        _mint(msg.sender, 5e26);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function bridgeMint(address account, uint256 amount) external onlyBridgeAdmin {
        require(_totalBridgtSupply >= amount, "Not to exceed bridgeMint");
        _mint(account, amount);
        _totalBridgtSupply -= amount;
    }

    function bridgeBurn(uint256 amount) external onlyBridgeAdmin {
        _burn(msg.sender, amount);
        _totalBridgtSupply += amount;
    }

    function setBridgeAdmin(address account, bool isAdmin_) external onlyOwner {
        _bridgeAdmins[account] = isAdmin_;
        if (isAdmin_ == false)
        {
            delete _bridgeAdmins[account];
        }
    }

    function isBridgeAdmin(address account) public view returns(bool) {
        return _bridgeAdmins[account];
    }

    modifier onlyBridgeAdmin() {
        require(_bridgeAdmins[_msgSender()] == true, "Ownable: caller is not the bridgeAdmins");
        _;
    }

    function setPolicemans(address account, bool _isPolicemans) external onlyOwner {
        _policemans[account] = _isPolicemans;
        if (_isPolicemans == false)
        {
            delete _policemans[account];
        }
    }

    function isPolicemans(address account) public view returns(bool) {
        return _policemans[account];
    }

    modifier onlyPolicemans(){
        require(_policemans[_msgSender()] == true, "Ownable: caller is not the administrator");
        _;
    }

    function setProhibitFrom(address account, bool isNotFrom) public onlyPolicemans
    {
        _prohibitFrom[account] = isNotFrom;
        if (isNotFrom == false)
        {
            delete _prohibitFrom[account];
        }
    }

    function inProhibitFrom(address account) public view returns (bool)
    {
        return _prohibitFrom[account];
    }

    function setProhibitTo(address account, bool isNotTo) public onlyPolicemans
    {
        _prohibitTo[account] = true;
        if (isNotTo == false)
        {
            delete _prohibitTo[account];
        }
    }

    function inProhibitTo(address account) public view returns (bool)
    {
        return _prohibitTo[account];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal view override {
        if (totalSupply() > 0)
        {
            require(this.inProhibitFrom(from) == false, "ERC20: no transfer out");
            require(this.inProhibitTo(to) == false, "ERC20: no transfer in");
            amount;
        }
    }
}