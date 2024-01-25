# terraform-useful-code


## moduleのtest
moduleで作成したリソースに対して、testを行うことができます。  
IAM Policyの権限が問題ないかや、使い方のメモを残すなどに利用してください。

### 実行方法
- direnv をインストールしてください。
    - `curl -sfL https://direnv.net/install.sh | bash`
    - ref: https://github.com/direnv/direnv/blob/master/docs/installation.md
- tf_pytest をインストールします。
  - `pip install -e ${GIT_REPOSITORY_ROOT_DIR}/scripts/tf_pytest/`
- 以下のように実行します:

```
cd ${TEST_IMPLED_MODULE}/test/pytest
LOG_LEVEL=INFO pytest -s
```
