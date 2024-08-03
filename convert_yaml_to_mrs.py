import os
import subprocess
import time

# 配置变量
GIT_USERNAME = "github-actions[bot]"
GIT_EMAIL = "github-actions[bot]@users.noreply.github.com"
GITHUB_TOKEN = os.getenv("TOKEN")
GIT_REPO = "https://github.com/REIJI007/AdBlock_Rule_For_Clash.git"  # 你的 GitHub 仓库地址
FILES_TO_CONVERT = [("adblock_reject.yaml", "adblock_reject.mrs"),
                    ("adblock_reject_change.yaml", "adblock_reject_change.mrs")]

# 转换 YAML 文件为 MRS 文件
def convert_yaml_to_mrs():
    for yaml_file, mrs_file in FILES_TO_CONVERT:
        print(f"Converting {yaml_file} to {mrs_file}")
        subprocess.run(["mihomo", "convert-ruleset", "domain/ipcidr", "yaml", yaml_file, mrs_file], check=True)
        print(f"Conversion completed for {yaml_file}")

# 提交并推送更改
def commit_and_push():
    subprocess.run(["git", "config", "--global", "user.name", GIT_USERNAME], check=True)
    subprocess.run(["git", "config", "--global", "user.email", GIT_EMAIL], check=True)
    subprocess.run(["git", "add", "*.mrs"], check=True)
    subprocess.run(["git", "commit", "-m", "Convert YAML to MRS"], check=True)
    subprocess.run(["git", "push", "-f", f"https://{GIT_USERNAME}:{GITHUB_TOKEN}@{GIT_REPO}"], check=True)

# 运行脚本
def main():
    max_retries = 3
    for attempt in range(max_retries):
        try:
            convert_yaml_to_mrs()
            commit_and_push()
            print("Conversion and push successful.")
            break
        except subprocess.CalledProcessError as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            time.sleep(10)  # 等待 10 秒后重试
            if attempt == max_retries - 1:
                print("Max retries reached. Exiting.")
                raise

if __name__ == "__main__":
    main()
