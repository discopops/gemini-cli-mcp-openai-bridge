# AGENT.md

## Project Summary
This repository contains the `gemini-cli-bridge` server application, designed to extend the `gemini-cli` ecosystem. It functions as both an MCP Toolkit, exposing `gemini-cli`'s built-in tools via a unified MCP endpoint, and an OpenAI-Compatible API Bridge, allowing third-party tools to interact with Gemini models through a standard OpenAI Chat Completions API.

## Key Technologies/Frameworks
- **Node.js (v18+)**: The primary runtime environment.
- **Gemini CLI**: Integrated as a submodule, providing core AI workflow capabilities and underlying Gemini model access.
- **Model Context Protocol (MCP)**: Used for exposing `gemini-cli` tools.
- **OpenAI API Standard**: Implemented for chat completions and model listing endpoints.
- **TypeScript**: Indicated by `tsconfig.json` and `.ts` files, suggesting strong typing and modern JavaScript development.

## Main Features
- **MCP Toolkit**: Exposes `gemini-cli`'s native tools for programmatic access.
- **OpenAI-Compatible API Bridge**: Provides `/v1/chat/completions` and `/v1/models` endpoints, supporting streaming and non-streaming requests for Gemini models.
- **External MCP Tool Aggregation**: Ability to connect to and proxy tools from other MCP servers (under specific security modes).
- **Flexible Configuration**: Allows customization of LLM models for tool execution, and inherits `gemini-cli`'s authentication and settings.
- **Robust Security Policies**: Offers `read-only`, `edit`, `configured`, and `yolo` modes to control tool execution, protecting the local environment.

## Architectural Patterns
- **Proxy/Bridge Pattern**: The application acts as a middle layer, translating requests between OpenAI/MCP clients and the `gemini-cli`.
- **Modular Design**: The codebase is structured with clear separation between bridge logic, configuration, and utility functions.
- **Security Layer**: Integrates a configurable security model to safeguard against unintended operations, especially when interacting with powerful AI models and local system resources.