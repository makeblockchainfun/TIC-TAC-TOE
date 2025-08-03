// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicTacToe {
    address payable public player1;
    address payable public player2;
    uint8[3][3] public board; // 0 = empty, 1 = X, 2 = O
    address public currentPlayer;
    bool public gameStarted;
    bool public gameOver;
    
    // Reduced entry fee for testnet (0.001 ETH)
    uint256 public constant ENTRY_FEE = 0.001 ether;

    event GameStarted(address player1, address player2);
    event MoveMade(address player, uint8 x, uint8 y);
    event GameWon(address winner);
    event GameDraw();
    event FundsWithdrawn(address receiver, uint256 amount);

    modifier onlyPlayers() {
        require(msg.sender == player1 || msg.sender == player2, "Not a player");
        _;
    }

    modifier validMove(uint8 x, uint8 y) {
        require(x < 3 && y < 3, "Invalid move");
        require(board[x][y] == 0, "Cell already taken");
        _;
    }

    modifier gameActive() {
        require(gameStarted, "Game not started");
        require(!gameOver, "Game over");
        _;
    }

    function startGame() external payable {
        require(!gameStarted || gameOver, "Game already in progress");
        require(msg.value == ENTRY_FEE, "Incorrect ETH amount");

        if (player1 == address(0) || gameOver) {
            player1 = payable(msg.sender);
            resetBoard();
            gameStarted = false;
            gameOver = false;
        } else if (player2 == address(0) && msg.sender != player1) {
            player2 = payable(msg.sender);
            gameStarted = true;
            currentPlayer = player1;
            emit GameStarted(player1, player2);
        }
    }

    function makeMove(uint8 x, uint8 y) external onlyPlayers validMove(x, y) gameActive {
        require(msg.sender == currentPlayer, "Not your turn");

        // Update board
        board[x][y] = currentPlayer == player1 ? 1 : 2;
        emit MoveMade(msg.sender, x, y);

        // Check game state
        if (isWinner()) {
            gameOver = true;
            address payable winner = payable(currentPlayer);
            uint256 prize = address(this).balance;
            resetPlayers();
            (bool sent, ) = winner.call{value: prize}("");
            require(sent, "Transfer failed");
            emit GameWon(winner);
        } else if (isDraw()) {
            gameOver = true;
            uint256 balance = address(this).balance;
            uint256 half = balance / 2;
            resetPlayers();
            (bool sent1, ) = player1.call{value: half}("");
            (bool sent2, ) = player2.call{value: half}("");
            require(sent1 && sent2, "Transfer failed");
            emit GameDraw();
        } else {
            // Switch turns
            currentPlayer = currentPlayer == player1 ? player2 : player1;
        }
    }

    // Allows player1 to withdraw if game never started
    function withdraw() external {
        require(!gameStarted, "Game active");
        require(msg.sender == player1, "Not player1");
        require(player2 == address(0), "Player2 exists");
        
        uint256 amount = address(this).balance;
        player1 = payable(address(0));
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Transfer failed");
        emit FundsWithdrawn(msg.sender, amount);
    }

    function getBoard() external view returns (uint8[3][3] memory) {
        return board;
    }

    function resetBoard() internal {
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                board[i][j] = 0;
            }
        }
    }

    function resetPlayers() internal {
        player1 = payable(address(0));
        player2 = payable(address(0));
        currentPlayer = address(0);
        gameStarted = false;
    }

    function isWinner() private view returns (bool) {
        uint8 symbol = currentPlayer == player1 ? 1 : 2;
        
        // Check rows
        for (uint8 i = 0; i < 3; i++) {
            if (
                board[i][0] == symbol &&
                board[i][1] == symbol &&
                board[i][2] == symbol
            ) return true;
        }
        
        // Check columns
        for (uint8 j = 0; j < 3; j++) {
            if (
                board[0][j] == symbol &&
                board[1][j] == symbol &&
                board[2][j] == symbol
            ) return true;
        }
        
        // Check diagonals
        if (
            board[0][0] == symbol &&
            board[1][1] == symbol &&
            board[2][2] == symbol
        ) return true;
        
        if (
            board[0][2] == symbol &&
            board[1][1] == symbol &&
            board[2][0] == symbol
        ) return true;
        
        return false;
    }

    function isDraw() internal view returns (bool) {
        for (uint8 i = 0; i < 3; i++) {
            for (uint8 j = 0; j < 3; j++) {
                if (board[i][j] == 0) return false;
            }
        }
        return true;
    }
    
    // Safety: Contract shouldn't hold ETH indefinitely
    receive() external payable {
        require(gameStarted, "Game not active");
    }
}
