#!/usr/bin/env python

from openai import OpenAI
from pathlib import Path
from datetime import datetime

import anthropic
import base64
import click
import os
import sys

from llm_utils import invoke_search_agent

prompts = ["eval_methods", "significant_problems", "identifier_check"]

base_dir = Path(os.path.dirname(os.path.abspath(__file__))).parent.absolute()


def create_message(prompt_name, prompt_dir, **kwargs):
    """Creates the prompt to evaluate the notebook.
    """
    prompt_file = os.path.join(prompt_dir, f"{prompt_name}.txt")
    with open(prompt_file) as prompt_file:
        prompt_tpl = prompt_file.read()

    return prompt_tpl.format(**kwargs)


def execute_openai(prompt, file_contents=None, upload_filename=None, model="gpt-5"):
    """Runs a prompt with PDF upload against OpenAI"""
    client = OpenAI()

    if file_contents:
        response = client.responses.create(
            model="gpt-5",
            prompt_cache_retention="24h",
            input=[{
                "role": "user",
                "content": [
                    {
                        "type": "input_text",
                        "text": prompt
                    },
                    {
                        "type": "input_file",
                        "filename": upload_filename,
                        "file_data": f"data:application/pdf;base64,{file_contents}"
                    }
                ]
            }] # type: ignore
        )
    else:
        response = client.responses.create(
            model=model,
            input=[{
                "role": "user",
                "content": [
                    {
                        "type": "input_text",
                        "text": prompt
                    }
                ]
            }]
        )

    return response.output_text


def execute_claude(prompt, file_contents=None, model="claude-sonnet-4-5"):
    """Runs a prompt with PDF upload against Claude."""
    client = anthropic.Anthropic()

    if file_contents:
        message = client.messages.create(
            prompt_cache_retention="24h",
            model=model,
            max_tokens=20000,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "document",
                            "source": {
                                "type": "base64",
                                "media_type": "application/pdf",
                                "data": file_contents
                            }
                        },
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]
        )
    else:
        message = client.messages.create(
            model=model,
            max_tokens=20000,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        }
                    ]
                }
            ]        
        )

    return message.content[0].text


def run_evaluation(prompt_name, input_filename, platform,
                   provider,
                   prompt_dir=os.path.join(base_dir, "prompts")):
    """Runs the evaluation and returns the results.
    """
    basename = os.path.basename(input_filename)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    upload_filename = f"{timestamp}_{basename}"

    input_dict = {
        "filename": input_filename,
        "platform": platform
    }

    prompt = create_message(prompt_name, prompt_dir, **input_dict)

    # Get base64 encoded file contents for upload
    with open(input_filename, "rb") as handle:
        file_contents = base64.b64encode(handle.read()).decode("utf-8")

    if provider == "openai":
        response = execute_openai(prompt, file_contents=file_contents,
                                  upload_filename=upload_filename)
    elif provider == "claude":
        response = execute_claude(prompt, file_contents=file_contents)
    
    else:
        raise ValueError("No valid provider chosen")

    return input_filename, response


def run_problems(prompt_name, input_filename, platform, provider,
                 prompt_dir=os.path.join(base_dir, "prompts")):
    """Runs the problem summarization on the output.
    """
    basename = os.path.basename(input_filename)

    with open(input_filename) as fh:
        file_contents = fh.read()

    input_dict = {
        "file_name": basename,
        "platform": platform,
        "evaluation_text": file_contents
    }

    prompt = create_message(prompt_name, prompt_dir, **input_dict)

    if provider == "openai":
        response = execute_openai(prompt)
    elif provider == "claude":
        response = execute_claude(prompt)

    return response


@click.command()
@click.option("--prompt-name", default="eval_methods", help="The prompt to use")
@click.option("--platform", default="NA")
@click.option("--provider", default="openai")
@click.argument("filename", nargs=1)
def run_eval(prompt_name, filename, platform, provider):
    """Run an evaluation prompt."""
    if prompt_name not in prompts:
        click.echo(f"prompt must be one of [{'.'.join(prompts)}]")
        sys.exit(1)

    if prompt_name == "eval_methods":
        _, response = run_evaluation(prompt_name, filename, platform, provider)
    elif prompt_name == "significant_problems":
        response = run_problems(prompt_name, filename, platform, provider)
    elif prompt_name == "identifier_check":
        response = invoke_search_agent(os.path.join(base_dir, "prompts"), prompt_name, 
                                       filename, "gpt-5", platform=platform)
        response = response["messages"][-1].text # Get the last message.

    click.echo(response)


if __name__ == "__main__":
    run_eval()
