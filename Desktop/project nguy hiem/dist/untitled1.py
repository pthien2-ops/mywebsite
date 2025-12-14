import socket
import os
import tkinter as tk
from tkinter import filedialog, messagebox

PORT = 5000
BUFFER_SIZE = 65536  # 64KB


class ClientGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("File Client")
        self.root.geometry("500x360")

        tk.Label(root, text="Server IP:").pack()
        self.ip_entry = tk.Entry(root)
        self.ip_entry.pack(fill="x", padx=20)

        tk.Label(root, text="Đường dẫn lưu file trên SERVER:").pack()
        self.server_path = tk.Entry(root)
        self.server_path.pack(fill="x", padx=20)

        self.open_var = tk.BooleanVar()
        tk.Checkbutton(root, text="Mở file trên server sau khi gửi", variable=self.open_var).pack(pady=5)

        tk.Button(root, text="Chọn file", command=self.choose_file).pack(pady=5)
        self.file_label = tk.Label(root, text="Chưa chọn file")
        self.file_label.pack()

        tk.Button(root, text="GỬI FILE", bg="#4CAF50", fg="white", command=self.send_file).pack(pady=10)
        tk.Button(root, text="TẮT SERVER", bg="#F44336", fg="white", command=self.shutdown_server).pack()

        self.filepath = None

    def choose_file(self):
        self.filepath = filedialog.askopenfilename()
        if self.filepath:
            self.file_label.config(text=os.path.basename(self.filepath))

    def send_file(self):
        if not self.filepath:
            messagebox.showerror("Lỗi", "Chưa chọn file")
            return

        ip = self.ip_entry.get().strip()
        save_path = self.server_path.get().strip()

        filesize = os.path.getsize(self.filepath)
        filename = os.path.basename(self.filepath)
        open_flag = "OPEN" if self.open_var.get() else "NOOPEN"

        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                s.connect((ip, PORT))

                header = f"SEND_FILE|{filename}|{filesize}|{save_path}|{open_flag}\n"
                s.sendall(header.encode("utf-8"))

                with open(self.filepath, "rb") as f:
                    while True:
                        chunk = f.read(BUFFER_SIZE)
                        if not chunk:
                            break
                        s.sendall(chunk)

                s.recv(1024)
                messagebox.showinfo("OK", "Gửi file thành công")

        except Exception as e:
            messagebox.showerror("Lỗi", str(e))

    def shutdown_server(self):
        ip = self.ip_entry.get().strip()
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect((ip, PORT))
                s.sendall(b"SHUTDOWN_SERVER")
                messagebox.showinfo("Server", s.recv(1024).decode())
        except Exception as e:
            messagebox.showerror("Lỗi", str(e))


if __name__ == "__main__":
    root = tk.Tk()
    ClientGUI(root)
    root.mainloop()
