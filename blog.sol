// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Blog {
    struct User {
        bool exists;
        string nickname;
    }

    struct BlogPost {
        uint id;
        address author;
        string title;
        string content;
        uint likes;
        uint reports;
        bool exists;
    }

    uint public reportThreshold = 5;
    uint public blogCounter = 0;

    mapping(address => User) public users;
    mapping(uint => BlogPost) public blogPosts;
    mapping(uint => mapping(address => bool)) public likedPosts;
    mapping(uint => mapping(address => bool)) public reportedPosts;

    event AccountCreated(address user, string nickname);
    event BlogPosted(uint id, address author, string title);
    event BlogLiked(uint id, address user);
    event BlogReported(uint id, address user);
    event BlogRemoved(uint id);

    modifier onlyExistingUser() {
        require(users[msg.sender].exists, "User does not have an account.");
        _;
    }

    function createAccount(string memory _nickname) external {
        require(!users[msg.sender].exists, "User already has an account.");
        users[msg.sender] = User(true, _nickname);
        emit AccountCreated(msg.sender, _nickname);
    }

    function postBlog(string memory _title, string memory _content) external onlyExistingUser {
        blogCounter++;
        blogPosts[blogCounter] = BlogPost(blogCounter, msg.sender, _title, _content, 0, 0, true);
        emit BlogPosted(blogCounter, msg.sender, _title);
    }

    function likeBlog(uint _id) external onlyExistingUser {
        require(blogPosts[_id].exists, "Blog post does not exist.");
        require(blogPosts[_id].author != msg.sender, "Cannot like your own blog post.");
        require(!likedPosts[_id][msg.sender], "User has already liked this post.");

        likedPosts[_id][msg.sender] = true;
        blogPosts[_id].likes++;
        emit BlogLiked(_id, msg.sender);
    }

    function reportBlog(uint _id) external onlyExistingUser {
        require(blogPosts[_id].exists, "Blog post does not exist.");
        require(blogPosts[_id].author != msg.sender, "Cannot report your own blog post.");
        require(!reportedPosts[_id][msg.sender], "User has already reported this post.");

        reportedPosts[_id][msg.sender] = true;
        blogPosts[_id].reports++;

        emit BlogReported(_id, msg.sender);

        if (blogPosts[_id].reports >= reportThreshold) {
            delete blogPosts[_id];
            emit BlogRemoved(_id);
        }
    }

    function getBlog(uint _id) external view returns (BlogPost memory) {
        require(blogPosts[_id].exists, "Blog post does not exist.");
        return blogPosts[_id];
    }

    function getAllBlogs() external view returns (BlogPost[] memory) {
        BlogPost[] memory blogs = new BlogPost[](blogCounter);
        uint counter = 0;

        for (uint i = 1; i <= blogCounter; i++) {
            if (blogPosts[i].exists) {
                blogs[counter] = blogPosts[i];
                counter++;
            }
        }

        BlogPost[] memory existingBlogs = new BlogPost[](counter);
        for (uint j = 0; j < counter; j++) {
            existingBlogs[j] = blogs[j];
        }

        return existingBlogs;
    }

    function getTotalLikes(uint _id) external view returns (uint) {
        require(blogPosts[_id].exists, "Blog post does not exist.");
        return blogPosts[_id].likes;
    }
}
