/**
 * Project-LLMS.txt Prompt Improvements
 * 
 * Purpose: Enhance the prompt that generates the project architecture, file tree, and implementation plan
 * 
 * Current challenges:
 * - Insufficient guidance on centralized type definitions and interfaces
 * - Unclear architecture for easy migration from mock data to Supabase
 * - May not adequately separate data access from UI components
 * - Could better define state management patterns using Zustand
 * - Task tracking may need more structure for progress monitoring
 * - Placeholder file generation needs more explicit format guidance
 * 
 * Before implementation, need:
 * - Example output of project-llms.txt from recent project
 * - Current prompt used to generate project-llms.txt
 * - Specific architectural patterns desired for database abstraction
 * - Examples of implementation issues encountered with current approach
 * 
 * v2 Updates (2025-05-30):
 * - Analyzed K-beauty project-llms.txt output
 * - Maintaining general structure of original prompt
 * - Adding more specific guidance on architecture while keeping flexible approach
 * - Focusing on clean separation between UI and data for Supabase migration
 */

Analyze the current project and create a comprehensive project plan in /project-llms.txt including:

## 1. Project Overview
- Brief description of the application purpose
- Core features and value proposition
- Technical stack summary (React, TypeScript, Tailwind)

## 2. Complete File Tree Structure
Create a detailed file tree in markdown that includes ALL necessary files for:

```
src/
├── components/               # UI components using atomic design principles
│   ├── ui/                   # Atoms (basic building blocks)
│   │   ├── button.tsx        # Reusable buttons
│   │   ├── input.tsx         # Form inputs
│   │   ├── ...
│   ├── compound/             # Molecules (combinations of atoms)
│   │   ├── form-field.tsx    # Label + input + error message
│   │   ├── search-bar.tsx    # Search input + button
│   │   ├── ...
│   ├── blocks/               # Organisms (complex UI sections)
│   │   ├── navigation-bar.tsx # Main navigation
│   │   ├── product-card.tsx  # Product display
│   │   ├── ...
│   ├── layout/               # Layout components and templates
│   │   ├── app-shell.tsx     # Main layout wrapper
│   │   ├── ...
│   └── pages/                # Page components
│       ├── home.tsx          # Homepage
│       ├── ...
├── types/                    # CENTRALIZED TypeScript definitions
│   ├── models.ts             # Data model interfaces
│   ├── api.ts                # API response types
│   ├── ...
├── stores/                   # Zustand state management
│   ├── user-store.ts         # User authentication state
│   ├── product-store.ts      # Product catalog state
│   ├── ...
├── services/                 # API and service layer
│   ├── base-service.ts       # Base service with common methods
│   ├── product-service.ts    # Product-related API calls
│   ├── ...
├── data/                     # Mock data for development
│   ├── products.ts           # Product mock data
│   ├── ...
├── hooks/                    # Custom React hooks
│   ├── use-media-query.ts    # Responsive design hooks
│   ├── ...
├── utils/                    # Utility functions
│   ├── formatters.ts         # Data formatting utilities
│   ├── ...
└── assets/                   # Static assets
    ├── images/               # Image files
    ├── ...
```

Ensure the file tree follows these principles:
- Complete coverage of ALL application needs
- Clear separation between UI components and data management
- Logical grouping of related files
- Consistent naming conventions (kebab-case for files, PascalCase for components)
- Progressive disclosure of complexity (atoms → molecules → organisms → pages)

## 3. Data Architecture
Design a modular data architecture with clean separation between layers:

1. **Type Definitions** (in `/types` folder)
   - Create interfaces for ALL data models used in the application
   - Define reusable types that can be shared across components
   - Design types to match future Supabase schema

2. **State Management** (in `/stores` folder)
   - Create Zustand stores that only interact with services, never directly with data
   - Implement stores with loading, error, and data states
   - Design for easy refresh and cache invalidation

3. **Service Layer** (in `/services` folder)
   - Create service classes/functions that encapsulate all API logic
   - Implement with clean interfaces that can be swapped from mock to Supabase
   - Handle error catching, request formatting, and response parsing

4. **Mock Data** (in `/data` folder)
   - Create realistic mock data that mirrors the expected database schema
   - Include sufficient variation to test all UI states
   - Design to be easily replaced by Supabase queries later

Example service pattern for easy Supabase migration:
```typescript
// Base service interface pattern
export interface ProductService {
  getProducts(): Promise<Product[]>;
  getProduct(id: string): Promise<Product>;
  createProduct(data: ProductInput): Promise<Product>;
  updateProduct(id: string, data: Partial<ProductInput>): Promise<Product>;
  deleteProduct(id: string): Promise<void>;
}

// Mock implementation during development
export class MockProductService implements ProductService {
  async getProducts(): Promise<Product[]> {
    return mockProducts; // From local data
  }
  // Other methods...
}

// Future Supabase implementation (same interface)
export class SupabaseProductService implements ProductService {
  async getProducts(): Promise<Product[]> {
    return supabase.from('products').select('*');
  }
  // Other methods...
}

// Factory function to get the right implementation
export function getProductService(): ProductService {
  // Can be switched with a configuration flag
  return new MockProductService();
}
```

## 4. Feature Requirements
List all required features organized by section:
- Authentication and user management
- Core application features
- Secondary features and enhancements
- Administrative capabilities

For each feature, include:
- Description of functionality
- User stories or use cases
- Technical requirements
- Acceptance criteria

## 5. Implementation Tasks
Create a structured task list organized into phases:

1. **Foundation Phase**
   - Set up project architecture
   - Implement base UI components
   - Create service interfaces and mock implementations
   - Establish store structure

2. **Core Features Phase**
   - Implement primary user flows
   - Build main pages and navigation
   - Connect UI to stores and services

3. **Enhancement Phase**
   - Add secondary features
   - Implement edge cases and error handling
   - Optimize performance

4. **Polish Phase**
   - Refine UI/UX details
   - Add animations and transitions
   - Accessibility improvements
   - Testing and bug fixes

Format tasks to track progress:
- [ ] Task description (Component/File)
- [ ] Sub-task with clear completion criteria
- [ ] ...

## 6. Supabase Migration Plan
Include a specific section on migrating from mock data to Supabase:
- Authentication implementation with Supabase Auth
- Database schema design
- RLS (Row Level Security) policies
- API migration steps
- Required environment variables

## 7. Data Flow Diagram
Create a visual representation of how data flows through the application:
- User actions → Store updates → Service calls → UI updates
- Authentication flow
- Data loading and caching patterns
- Error handling paths

## Important Guidelines:

1. **For placeholder files**: Include ONLY 3-5 lines of comments explaining:
   - Purpose of the file
   - Key functionality
   - Related components or services
   - Expected props or parameters

2. **For component organization**: Follow atomic design principles strictly:
   - ui/ folder: Independent, reusable atoms (button, input, checkbox)
   - compound/ folder: Combinations of atoms (form-field, search-bar)
   - blocks/ folder: Complex, self-contained sections (forms, cards, headers)
   - layout/ folder: Page structure components (layouts, grids, containers)
   - pages/ folder: Full page components combining multiple organisms

3. **For data management**: Maintain strict separation between layers:
   - Components should NEVER directly import from /data
   - Components should ONLY interact with stores
   - Stores should ONLY interact with services
   - Services should encapsulate all data access logic

4. **For tasks**: Organize for incremental implementation:
   - Group related files that should be built together
   - Create logical dependencies between tasks
   - Design for implementation in batches of 10-20 files per cycle

This comprehensive project plan will serve as a blueprint for development, ensuring consistent architecture, clean separation of concerns, and a smooth migration path to Supabase when ready.