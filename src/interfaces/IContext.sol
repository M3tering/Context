// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IContext {
    struct Detail {
        // Identifiers
        uint256 tokenId;
        bytes32 publicKey;
        bytes32 processId;
        // Terms of Use
        uint16 energyPrice;
        uint16 escalator;
        uint48 blockInterval;
        uint48 lastCheckpoint;
    }

    event Register(uint256 indexed tokenId, bytes32 indexed publicKey, address from, uint256 timestamp);

    error CannotBeZero();
    error Unauthorized();

    function setup(
        uint256 tokenId,
        bytes32 publicKey,
        bytes32 processId,
        uint256 energyPrice,
        uint256 escalator,
        uint256 interval
    ) external;
}
