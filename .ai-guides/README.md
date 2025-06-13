# AI Guide Documentation

This repository contains guidance documents for effectively working with AI application builders like lovable.dev and bolt.new. These guides help create consistent, well-architected, mobile-first React applications.

## Guide Formats

Each guide follows a consistent format:

1. **Metadata Header**: Contains purpose, challenges, requirements, and version information
2. **Content Body**: Detailed instructions, examples, patterns, and best practices
3. **Implementation Guidance**: Specific tactical advice for execution

## Available Guides

### Core Architecture Guides

- **initial-prompt-improvements.md**: Complete guide for the initial prompt to establish project vision and design system with mobile-first principles, atomic design methodology, and responsive patterns.

- **project-llms-prompt-improvements.md**: Instructions for generating a comprehensive project plan with a complete file tree, data architecture, and implementation roadmap that enables easy migration to Supabase.

### Future Guides

Recommended guides to create:

#### Framework & Architecture Guides
- **atomic-design-components-guide.md**: Building component libraries using atomic design methodology (atoms → molecules → organisms → templates → pages)
- **zustand-store-patterns.md**: Effective state management patterns with Zustand for React applications
- **responsive-layout-patterns.md**: Mobile-first responsive layout implementations that scale from mobile to desktop
- **shadcn-ui-customization.md**: Extending and customizing shadcn/ui components while maintaining design consistency

#### Backend Integration Guides
- **supabase-migration-guide.md**: Transitioning from mock data to Supabase backend
- **appwrite-integration-guide.md**: Structuring applications for Appwrite backend services
- **firebase-auth-guide.md**: Implementing Firebase authentication with proper security patterns
- **mongodb-atlas-guide.md**: Working with MongoDB Atlas for database operations

#### UX Pattern Guides
- **mobile-navigation-patterns.md**: Implementation of bottom tabs, side drawer, and navigation transitions
- **gesture-interaction-guide.md**: Adding swipe, drag, and other touch gestures to mobile interfaces
- **form-ux-patterns.md**: Creating user-friendly form experiences with validation and feedback
- **dark-mode-implementation.md**: Adding and customizing dark mode with proper system preference detection

#### AI Integration Guides
- **anthropic-api-integration.md**: Adding Claude capabilities to applications
- **openai-assistants-integration.md**: Implementing OpenAI Assistants API
- **firecrawl-implementation.md**: Adding web search and content extraction capabilities
- **buildship-deployment-guide.md**: Streamlining deployment with Buildship

#### App-Inspired Pattern Guides
- **notion-like-editor.md**: Building block-based content editors similar to Notion
- **telegram-chat-interface.md**: Creating responsive chat interfaces with Telegram-inspired patterns
- **macos-design-patterns.md**: Implementing macOS desktop-like interfaces that remain mobile-friendly
- **whatsapp-message-patterns.md**: Message delivery, read receipts, and chat features like WhatsApp

## Instructions for Creating New Guides

When creating new guides for this collection:

1. **Follow the established format** with metadata, content body, and implementation guidance sections
2. **Use markdown formatting** for readability and structure
3. **Include concrete examples** with code snippets where appropriate
4. **Follow atomic design methodology** when discussing components
5. **Always prioritize mobile-first design** with progressive enhancement
6. **Include compatibility notes** for different AI builders (lovable.dev, bolt.new, etc.)
7. **Create placeholder examples** that follow the 3-5 line comment format

Each guide should provide both strategic understanding and tactical instructions that can be directly used with AI builders to create consistent, maintainable applications.
