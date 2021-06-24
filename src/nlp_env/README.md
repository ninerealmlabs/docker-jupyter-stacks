# NLP Environment

JupyterLab environment updated to include packages useful for Natural Language Processing (NLP) tasks.

For package details, see [`environment.yml`](./environment.yml) and [`requirements.txt`](./requirements.txt)
See also source `base_env` and `ds_env` image files.

**Notes:**
* The docker image copies a fix for `pattern==3.6` where StopIteration breaks in python 3.7+.  _We should keep an eye on `pattern`, as it appears development may have ceased._

## Image dependencies / inheritance
`base_env`
  └ `ds_env`
      └ `nlp_env`
