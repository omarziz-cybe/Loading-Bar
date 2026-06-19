# Dynamic Loading Bar in Assembly Language ⏳💻

## 📌 Project Overview
A visually dynamic graphical loading bar programmed entirely in low-level **Assembly Language**. This project demonstrates a deep understanding of computer architecture, memory management, and direct hardware manipulation.

Unlike high-level languages where graphics are handled by extensive libraries, this project required manually interacting with the system's video memory and utilizing BIOS interrupts to render shapes, control cursor positions, and manage execution delays.

## 🚀 Features
- **Direct Memory Access:** Interacts directly with the video memory (VGA/Text mode) to draw the loading bar frame and fill it dynamically.
- **Hardware-Level Control:** Utilizes BIOS interrupts (e.g., `INT 10h`) for precise screen rendering, cursor manipulation, and color styling.
- **Custom Delay Logic:** Implemented manual timing loops (or `INT 15h` for system wait) to control the animation speed of the loading bar.
- **Zero Dependencies:** Pure Assembly code with absolutely no external libraries or high-level wrappers.

## 🛠️ Technologies & Tools Used
- **Programming Language:** x86 Assembly Language
- **Assembler / Emulator:** [emu8086 / TASM / MASM / DOSBox - اختار اللي استخدمته]
- **Core Concepts:** Video Memory Rendering, Interrupts (ISRs), Registers Management.

## ⚙️ How to Run the Project
1. Clone the repository to your local machine:
   ```bash
   git clone [https://github.com/omarziz-cybe/Assembly-Loading-Bar.git](https://github.com/omarziz-cybe/Assembly-Loading-Bar.git)
