import base64
import os.path

from langchain.agents import create_agent
from langchain_community.tools import DuckDuckGoSearchRun

def create_message(prompt_name, prompt_dir, **kwargs):
    """Creates the prompt to evaluate the notebook.
    """
    prompt_file = os.path.join(prompt_dir, f"{prompt_name}.txt")
    with open(prompt_file) as prompt_file:
        prompt_tpl = prompt_file.read()
            
    return prompt_tpl.format(**kwargs)

 
def invoke_search_agent(prompt_dir, prompt_name, filename, model_name, **kwargs):
    """Invokes the agent with web search enabled via DuckDuckGo
    """

    agent = create_agent(
        model=model_name,
        tools=[DuckDuckGoSearchRun()]
    )

    # Get base64 encoded file contents for upload
    with open(filename, "rb") as handle:
        file_contents = base64.b64encode(handle.read()).decode("utf-8")

    # Create the prompt
    kwargs["filename"] = os.path.basename(filename)
    prompt = create_message(prompt_name, prompt_dir, **kwargs)

    result = agent.invoke({
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt,
                    },
                    {
                        "type": "file",
                        "filename": os.path.basename(filename),
                        "base64": file_contents,
                        "mime_type": "application/pdf"
                    }
                ]
            }
        ]
    })

    for message in result["messages"]:
        message.pretty_print()

    return result