### Summary
This document summarise my recent learning notes on setting up Airflow DAGs in an AWS EC2 instance. 

#### Challenges & Learnings
1. `snowflake_test.py` can't pass the DAGs recognition from Airflow server. I kept got error from `configparser` package stating NoSession. Ultimately, I found out the root cause as such package was not installed within Airflow python environment on the server. Below are a few useful commands.
    -  Ensure to first activate Airflow python virtual environment.
    - `which python` and `which airflow` to check whether the running environment is aligned with my local running environment.
    - `pip show configparser` this command will tell you the version of configparser in my environment; or help me find out that this package is not in place.
    - `pip install configparser` if installation is needed.
    - How could I test if the specific code snippets referring this package works as expected. One thing I tried is to get into python interactive environment and write some lines of sample code. If the output is [], it indicates that the configuration file is not read properly; but if `NoSectionError` occurs, it indicates the config file might be missing or malformed.
    ```
        python
        import configparser
        config = configparser.ConfigParser()
        config.read("your_config_file.ini")  # Replace with actual config file
        print(config.sections())
    ```
    - Now my code passed the above test, but I still received the error in Airflow UI. This turn out to result from me putting the configuration setup at global level, causing an incorrect execution context. 
        - The right way is to define a function in DAG file wrapping this snippet and and then refer to the wrapper function in task.
2. Another challenge faced is how to pass Snowflake_Ops instance I defined between two tasks.
    - The first trial I took is to convert my DAG into decorator style, but I faced error `'_TaskDecorator' object has no attribute <my_class_function>`. I learned that Airflow tasks (decorated with @task) do not return actual Python objects, but instead return XCom references. The error occurs because Airflow is trying to pass the _TaskDecorator object (representing the task) instead of the actual class instance.
    - ChatGPT suggested a few alternatives such as serialising the object or using pickle. However, I realised that I don't need to pass reference any more. As I switched to decorator style, I can directly call multiple python functions in a single task. 
3. I also found a few airflow cli commands very handy. 
    - `airflow dag list` and `airflow dag list-import-errors` helped me find out which dags succesfully registerd and if not, what are the errors behind the scenes. The beauty of these commands is that you don't rely on the UI. 
    - I sense that using cli to conduct test and tweak my codes is an advanced feature I need to pick up.
4. If a DAG job is stuck at retry/running status, you can go to DAG --> DAG runs and manually update its status to "Failed" to avoid waiting.

