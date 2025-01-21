// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import {IM3terContext} from "./interfaces/IM3terContext.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable@5.2.0/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable@5.2.0/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable@5.2.0/access/AccessControlUpgradeable.sol";

contract M3terContext is IM3terContext, Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    IERC721 public constant M3TER = IERC721(0x0000000000000000000000000000000000000000); // ToDo: set actual m3ter contract
    bytes32 public constant UPGRADER = keccak256("UPGRADER");
    bytes32 public constant CURATOR = keccak256("CURATOR");

    mapping(bytes32 => uint256) public processRegistry;
    mapping(bytes32 => uint256) public keyRegistry;
    mapping(uint256 => bytes32) public l2Allowlist;
    mapping(uint256 => Detail) public details;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address defaultAdmin) external initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(UPGRADER, defaultAdmin);
        _grantRole(CURATOR, defaultAdmin);
        __UUPSUpgradeable_init();
        __AccessControl_init();
    }

    function _curateL2Allowlist(uint256 chainId, bytes32 l2Address) external onlyRole(CURATOR) {
        l2Allowlist[chainId] = l2Address;
    }

    function setup(
        uint256 tokenId,
        bytes32 publicKey,
        bytes32 processId,
        uint256 tariff,
        uint256 escalator,
        uint256 interval
    ) external {
        if (msg.sender != M3TER.ownerOf(tokenId)) revert Unauthorized();
        if (tokenId == 0 || publicKey == 0 || processId == 0 || tariff == 0) revert CannotBeZero();
        details[tokenId] = Detail(tokenId, publicKey, processId, tariff, escalator, interval, block.number);

        emit Register(tokenId, publicKey, msg.sender, block.timestamp);
        processRegistry[processId] = tokenId;
        keyRegistry[publicKey] = tokenId;
    }

    function _authorizeUpgrade(address newImplementation) private override onlyRole(UPGRADER_ROLE) {}
}
