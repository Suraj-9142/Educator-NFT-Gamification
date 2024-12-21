// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EducatorNFTGamification {
    address public owner;
    uint256 public tokenCounter;

    struct NFTBadge {
        uint256 id;
        string name;
        string description;
        string metadataURI;
        address issuedTo;
    }

    mapping(uint256 => NFTBadge) public nftBadges;
    mapping(address => uint256[]) public educatorBadges;

    event BadgeIssued(address indexed educator, uint256 badgeId);
    event BadgeTransferred(uint256 badgeId, address from, address to);

    constructor() {
        owner = msg.sender;
        tokenCounter = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    modifier onlyEducator(address educator) {
        require(educator != address(0), "Invalid educator address.");
        _;
    }

    function issueBadge(
        address educator,
        string memory name,
        string memory description,
        string memory metadataURI
    ) public onlyOwner onlyEducator(educator) returns (uint256) {
        uint256 newId = tokenCounter;
        nftBadges[newId] = NFTBadge({
            id: newId,
            name: name,
            description: description,
            metadataURI: metadataURI,
            issuedTo: educator
        });

        educatorBadges[educator].push(newId);
        tokenCounter++;

        emit BadgeIssued(educator, newId);
        return newId;
    }

    function transferBadge(uint256 badgeId, address to) public {
        require(to != address(0), "Invalid address.");
        require(nftBadges[badgeId].issuedTo == msg.sender, "You do not own this badge.");

        nftBadges[badgeId].issuedTo = to;
        removeBadgeFromEducator(msg.sender, badgeId);
        educatorBadges[to].push(badgeId);

        emit BadgeTransferred(badgeId, msg.sender, to);
    }

    function getBadgesByEducator(address educator) public view returns (uint256[] memory) {
        return educatorBadges[educator];
    }

    function removeBadgeFromEducator(address educator, uint256 badgeId) internal {
        uint256[] storage badges = educatorBadges[educator];
        for (uint256 i = 0; i < badges.length; i++) {
            if (badges[i] == badgeId) {
                badges[i] = badges[badges.length - 1];
                badges.pop();
                break;
            }
        }
    }
}