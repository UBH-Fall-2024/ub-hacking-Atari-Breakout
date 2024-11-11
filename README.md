# Atari Breakout Game Clone (ARM Assembly)

### Hackathon Project - November 2024

This repository contains the code for a fully functional Atari Breakout game clone, written in ARM assembly language for the Tiva C microcontroller. The game simulates the classic 1976 Atari Breakout, where the player controls a paddle to bounce a ball into bricks, aiming to eliminate all bricks to win the game.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [How It Works](#how-it-works)
- [Challenges](#challenges)
- [Setup](#setup)
- [Future Improvements](#future-improvements)
- [License](#license)

## Overview

This project was developed during a hackathon and showcases the power of low-level assembly language programming. It uses interrupts to refresh the game board dynamically, simulates ball physics, and allows player-controlled paddle movement.

## Features
- **Real-time ball physics**: The ball bounces around the screen, interacting with the paddle and bricks.
- **Paddle control**: The player moves the paddle to hit the ball.
- **Brick collision detection**: Bricks are marked as "hit" and eliminated from the game when struck.
- **12 bricks to eliminate**: The goal is to clear all 12 bricks to win.
- **Interrupt-based game board refresh**: The game board is refreshed dynamically through timer interrupts.
- **Pause State**: The game board can be paused during any point.
  
## How It Works

- The game was written entirely in ARM assembly language, using the Tiva C microcontroller and Code Composer Studio.
- The game runs on a loop, where a timer interrupt refreshes the game board and checks for ball, paddle, and brick collisions.
- Paddle movement can be integrated with the two switches (SW1 and SW2) on the Tiva C board to control left and right movement (a future improvement).
- Ball trajectory is managed by tracking its X and Y coordinates, along with velocity changes upon hitting the paddle or walls.
- Pressing SW1 on the Tiva board will pause the game, pressing it again will unpause.
- The game can also be exited through the main menu prior to the game starting, or during the game through the pause menu.

## Challenges

The biggest challenge was managing the ball physics, particularly keeping track of the ball's position and velocity, and ensuring it bounced correctly off the paddle and walls. Debugging the mechanics in assembly language required careful attention to detail and patience.

## Setup

To run this project, you'll need the following:
1. **Tiva C Series Microcontroller**
2. **Code Composer Studio**
3. **Debugger/Programmer for the Tiva C**

Steps:
1. Clone this repository to your local machine.
2. Open the project in Code Composer Studio.
3. Flash the code onto your Tiva C microcontroller using a compatible programmer.
4. Run the game and control the paddle with the keyboard or Tiva C switches (if implemented).

## Future Improvements
- Fix existing bugs in ball-paddle collision detection.
- Implement paddle control using the Tiva C switches (SW1 for left, SW2 for right).
- Add scoring and lives system for a more complete gameplay experience.

## License

This project is open-source and available under the MIT License. Feel free to fork, modify, and contribute!
