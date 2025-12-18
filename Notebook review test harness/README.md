# Notebook Evaluation

This set of scripts and utilities is designed to enable LLM-based evaluation of Jupyter notebooks
produced by AI co-scientists designed to accelerate biomedical research workflows by automating
code generation for data retrieval, processing, and analysis.

This organization of this repo is below. Each of the functions in these files is described in
detail later in this README.

    ├── bin
    │   ├── llm_utils.py                Utilities for calling LLMs
    │   ├── per_question_summary.py     Summarizes data per-question
    │   ├── run_evaluation.py           Runs a single evaluation
    │   ├── run_evaluations.sh          Runs evaluation over a set of PDFs
    │   ├── run_problems.sh             Summarizes common problems identified by the judge prompt
    │   ├── summarize_results.py        Summarizes sets of results produced by multiple evaluations
    │   └── summarize_tools.py          Extracts resources/tools used across workflows evaluated
    ├── prompts
    │   ├── eval_methods.txt            A prompt to evaluate methods used by coding assistants
    │   ├── identifier_check.txt        A prompt to check validity of identifiers used as inputs [ALPHA]
    │   ├── significant_problems.txt    A prompt to summarize significant problems in evaluation outputs
    │   └── user_questions.txt          A prompt to extract questions asked by the assistant to the user
    ├── README.md
    └── requirements.txt


# Generating data

The prompts used in this evaluation take PDF files as input. To generate these, either use
the PDF export functionality in Jupyter notebook, or print to PDF directly - the latter
requires starting the notebook server with `jupter lab` vs `jupyter notebook` to get
appropriate formatting. If these methods do not work, exporting to HTML, then printing
is another method to produce PDFs.

# Setting up your environment

The suggested method for running these scripts is to use a virtual environment, either
created using the `virtualenv` module or with a python environment manager (e.g. 
Anaconda, pyenv, pipenv). Once the environment has been created, install all of the
necessary packages:

    pip install -r requirements.txt

Next, set the API keys for the LLM providers that will be used. For OpenAI models, set
`OPENAI_API_KEY` and for Antropic models, set `ANTHROPIC_API_KEY`. If you need to create
an API key, see the instructions below

* OpenAI: https://platform.openai.com/account/api-keys
* Anthropic: https://platform.claude.com/docs/en/get-started

# Evaluating Notebook Results

The `run_evaluation.py` script supports evaluation of Jupyter notebooks produced by 
coding assistants, as well as downstream analysis of these results. This 
functionality is enabled by using the `--prompt-name` option. The available prompts are:

* `eval_methods`: This prompt evaluates the methods used by the assistant
* `significant_problems`: This prompt takes the output of the `eval_methods` prompt and
   summarizes the major problems identified by the LLM judge.
* `identifier_check`: This prompt uses a [LangChain](https://www.langchain.com/) agent to
   look up any gene/protein identifiers used as input to check whether the identifier corresponds to
   the appropriate entity. Lookups are peformed via web search (DuckDuckGo). 
   Note that this prompt is a work in progress and likely could be improved. 

The prompts can be found in the `prompts` directory. 

## Evaluating a notebook

To evaluate a notebook, run

    run_evaluation.py --prompt-name eval_methods --provider [openai/claude] --platform [Name of the platform that produced the notebook] [PDF to process]

This produces output with the following sections:

* A header section with four rows, containing the following information:
    - The input filename
    - The platform being evaluated
    - A list of all user queries in the dialog
    - A list of resources and tools used by the assistant to respond to queries 
* A tabular section with the following columns
    - Eval Question Number: The question number specified in the prompt
    - Eval Question: The Question as specified in the prompt
    - Assessment: Yes, no, unsure, or not applicable
    - Evidence and Reasning: The LLM-provided reasoning for the assessment
    - Evidence Snippets: Verbatim text from the dialog supporting the reasoning and assessment
    - Impact Level: If assessment is no, an assessment of the impact (Low, Medium, High)
* A 30-100 word summary containing strengths, key issues, and recommendations for improvement
 
## Summarizing Results

To summarize results, run

    run_evaluation.py --prompt-name eval_methods --provider [openai/claude] --platform [Name of the platform that produced the notebook] [Results file from evaluation prompt]

Thius produces output with the two sections

* A header section with four rows, containing the same information in the evaluation output.
* A tabular section with the following columns
    - Error description: A description of the unique error identified
    - Impact level: An assessment of the impact of that error on the workflow (Low/Medium/High)

## Checking Identifiers

To check identifiers, run
    run_evaluation.py --prompt-name eval_methods --provider [openai/claude] --platform [Name of the platform that produced the notebook] [Results file from evaluation prompt]

# Wrappers for running multiple evaluations

## Evaluating PDFs

The `run_evaluations.sh` bash script will take a folder of PDFs and evaluate them. By default this is
done in triplicate, the number of runs can be changed by modifying the first loop in the shell file.
This script is run with the following arguments:

    run_evaluations.sh [FOLDER CONTAINING PDFs] [openai/claude] [platform]

This will create a set of files of the format:

    [PDF NAME].[PROVIDER].[RUN]

in the directory containing the pdf files. Note: this does not use available batching APIs, and the process could likely be further optimized.

## Summarizing problems from outputs

The `run_problems.sh` script can then be used to summarize the output (as implemented just the first run)
and identify specific problems. 

    run_problems.sh [FOLDER CONTAINING PDFs] [platform]

This will produce the following file corresponding to each PDF in the directory:

    [PDF NAME].openai.1.problems.txt

Note that this script runs only with OpenAI as a provider, based on choices made during generation
of data for evaluation. It could be modified to use Claude in the future.

## Aggregating output for Analysis

There are two additional scripts that will aggregate results for analysis. The first,
`per_question_summary.py` will parse all of the output in a directory and generate a single 
file with the following columns in addition to the output in each file

* Input PDF: The input filename
* Replicate: The replicate number

This script is run as follows:

    per_question_summary.py [directory]

A second script extracts the tools and resources identified by the LLM judge. 
This produces CSV output with the following columns:

* pdf_filename: The input filename
* number_of_tools: The number of tools used within the workflow, as identified by the LLM judge.
  Note that because of differences in output formatting, this number may be incorrect due to 
  errors in parsing, though all patterns previously seen have been handled.
* tools: The list of tools and resources as provided in the output

This is run as follows:

    summarize_tools.py [directory]

Both of these scripts assume `openai` as the provider chosen to generate the summaries, 
and output CSV to standard out.