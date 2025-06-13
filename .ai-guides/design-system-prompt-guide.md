/**
 * Design System Prompt Guide
 * 
 * Purpose: Create a comprehensive one-shot starter prompt for AI LLM builder tools like lovable.dev and bolt.new
 * to generate a complete, modular, mobile-first design system with all necessary components, layouts, and PWA setup
 * 
 * Current challenges:
 * - AI builders need complete design systems from a single prompt
 * - Inconsistent component creation across different sessions
 * - Missing mobile-first optimizations and PWA requirements
 * - Lack of mock data structure that mirrors real database schemas
 * - No standardized project file organization
 * 
 * Implementation approach:
 * - One comprehensive starter prompt with customizable header section
 * - Complete file tree with placeholder comments (2-3 lines, no code)
 * - PWA setup including manifest.json and proper icon structure
 * - Mock data architecture that easily migrates to real backends
 * - Modular component system that always works across devices
 * 
 * v1 Created (2025-06-05):
 * - Complete design system prompt template
 * - Mobile-first responsive components with container queries
 * - PWA installable requirements included
 * - Mock data structure mirroring real database patterns
 * - Automatic project-llms.txt generation
 */

# Design System Prompt Guide

## Overview

This guide provides a comprehensive one-shot starter prompt for AI LLM builder tools (lovable.dev, bolt.new, etc.) to create a complete mobile-first design system. The prompt is designed to generate everything needed for a modern PWA with modular components, responsive layouts, and a complete development foundation.

## Customizable Starter Prompt Template

### Part 1: Project Customization Header

**Replace this section with your specific project details:**

```
PROJECT CUSTOMIZATION (Replace with your specifics):
- App Name: [Your App Name]
- App Vision: [Brief description of what your app does]
- Target Audience: [Who will use this app]
- Color Palette: [e.g., "Modern blue and teal", "Warm sunset colors", "Professional navy and gold"]
- UI Style Reference: [e.g., "Clean like Notion", "Playful like Duolingo", "Elegant like Apple"]
- Key Features: [3-5 main features your app will have]
- Inspiration Apps: [2-3 apps that inspired your design direction]
```

### Part 2: Complete Design System Prompt

**Copy this entire prompt and paste into your AI builder after customizing Part 1:**

---

# Modern Mobile-First PWA Design System

Build a complete, production-ready React application with TypeScript, Tailwind CSS, and shadcn/ui components. Create a comprehensive design system that works flawlessly on mobile devices, looks beautiful on desktop, and serves as the foundation for a scalable application.

## 🎨 Design System Foundation

### Color System
Create a cohesive color palette based on: [INSERT YOUR COLOR PALETTE FROM PART 1]

```css
/* Adapt these base colors to match your chosen palette */
:root {
  /* Primary colors - CUSTOMIZE TO YOUR BRAND */
  --primary: [Your primary color HSL];
  --primary-foreground: [Contrasting text color];
  --secondary: [Your secondary color HSL];
  --secondary-foreground: [Contrasting text color];
  
  /* Semantic colors */
  --success: 142 76% 36%;
  --warning: 38 92% 50%;
  --error: 0 84% 60%;
  --info: 199 89% 48%;
  
  /* Neutral palette */
  --background: 0 0% 100%;
  --foreground: 222 47% 11%;
  --card: 0 0% 100%;
  --card-foreground: 222 47% 11%;
  --muted: 210 40% 96%;
  --muted-foreground: 215 16% 47%;
  --border: 214 32% 91%;
  --input: 214 32% 91%;
  --ring: var(--primary);
  
  /* Border radius system */
  --radius-sm: 0.375rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
  
  /* Dynamic viewport height for mobile */
  --vh: 1vh;
}

/* Dark mode variants */
.dark {
  --background: 222 47% 11%;
  --foreground: 210 40% 98%;
  --card: 222 47% 11%;
  --card-foreground: 210 40% 98%;
  --muted: 217 33% 17%;
  --muted-foreground: 215 20% 65%;
  --border: 217 33% 17%;
  --input: 217 33% 17%;
}
```

### Typography Scale
```css
/* Mobile-first responsive typography */
.text-display-xl { font-size: 2.25rem; line-height: 2.5rem; } /* 36px/40px mobile */
.text-display-l { font-size: 1.875rem; line-height: 2.25rem; } /* 30px/36px mobile */
.text-display-m { font-size: 1.5rem; line-height: 2rem; } /* 24px/32px mobile */

/* Scale up for desktop with responsive classes */
@media (min-width: 768px) {
  .text-display-xl { font-size: 4.5rem; line-height: 5rem; } /* 72px/80px desktop */
  .text-display-l { font-size: 3.75rem; line-height: 4.5rem; } /* 60px/72px desktop */
  .text-display-m { font-size: 3rem; line-height: 3.5rem; } /* 48px/56px desktop */
}
```

### Spacing System
Use a consistent 4px base unit (0.25rem) with this scale:
- 2xs: 2px
- xs: 4px  
- sm: 8px
- md: 12px
- base: 16px
- lg: 24px
- xl: 32px
- 2xl: 48px
- 3xl: 64px
- 4xl: 96px

## 📱 Mobile-First Component Architecture

### Core Design Principles
1. **Touch-First**: All interactive elements minimum 44px × 44px
2. **Thumb-Friendly**: Primary actions within easy thumb reach
3. **Performance-First**: Fast loading and smooth animations
4. **Container Query Responsive**: Components adapt to their container, not just viewport
5. **Progressive Enhancement**: Mobile foundation, desktop enhancement

### Essential Components to Create

#### 1. Layout Components (`/components/layout/`)

**AppShell** - Main application wrapper
```jsx
// Purpose: Main app structure with navigation, handles mobile/desktop layouts
// Features: Bottom nav (mobile), sidebar (desktop), main content area
// Responsive: Switches navigation pattern at md breakpoint
```

**MobileBottomNav** - Mobile navigation bar
```jsx
// Purpose: Fixed bottom navigation for mobile devices
// Features: 5 max items, safe area padding, active states
// Accessibility: Proper ARIA labels, keyboard navigation
```

**DesktopSidebar** - Desktop sidebar navigation
```jsx
// Purpose: Collapsible sidebar for desktop layouts
// Features: Expandable/collapsible, section grouping, active states
// Responsive: Hidden on mobile, visible from md breakpoint up
```

**TopAppBar** - Page header component
```jsx
// Purpose: Page title, actions, back navigation
// Features: Responsive layout, action buttons, breadcrumbs (desktop)
// Mobile: Compact design, essential actions only
```

#### 2. Navigation Components (`/components/navigation/`)

**BottomTabBar** - Tab-based navigation
```jsx
// Purpose: Primary navigation for mobile apps
// Features: Icon + label, badge support, active states
// Design: Fixed positioning, safe area insets
```

**SlideOutDrawer** - Overlay navigation drawer
```jsx
// Purpose: Secondary navigation and app menu
// Features: Smooth slide animation, backdrop, gesture support
// Mobile: Full screen overlay, easy thumb dismissal
```

**Breadcrumbs** - Hierarchical navigation
```jsx
// Purpose: Show current location in app hierarchy
// Features: Truncation on mobile, full path on desktop
// Responsive: Can hide on mobile, show on tablet+
```

#### 3. Form Components (`/components/forms/`)

**FormField** - Complete form field wrapper
```jsx
// Purpose: Label, input, error, help text grouping
// Features: Consistent spacing, error states, accessibility
// Mobile: Optimized input sizes, clear tap targets
```

**OneFieldForm** - Single field per step forms
```jsx
// Purpose: Optimized mobile form experience
// Features: Auto-focus, continue button, progress indicator
// Mobile: Full screen, minimal cognitive load
```

**MultiStepForm** - Wizard-style forms
```jsx
// Purpose: Break complex forms into manageable steps
// Features: Progress indicator, back/next navigation, validation
// Mobile: One step at a time, clear progress
```

#### 4. Card Layouts (`/components/cards/`)

**ProductCard** - Product display component
```jsx
// Purpose: Showcase products with image, details, actions
// Features: Responsive images, price display, action buttons
// Mobile: Stack layout, touch-friendly actions
```

**InfoCard** - General information card
```jsx
// Purpose: Display any structured information
// Features: Header, content, footer sections, variants
// Responsive: Flexible layout adaptation
```

**StatsCard** - Metrics and statistics display
```jsx
// Purpose: Show KPIs, numbers, trends
// Features: Icon, number, label, trend indicator
// Visual: Clear typography hierarchy, color coding
```

#### 5. Interactive Components (`/components/interactive/`)

**BottomSheet** - Modal alternative for mobile
```jsx
// Purpose: Modal content optimized for mobile interaction
// Features: Drag to dismiss, various heights, smooth animation
// Mobile: Native-feeling interaction pattern
```

**ActionSheet** - Context menu for mobile
```jsx
// Purpose: List of actions in mobile-friendly format
// Features: Large touch targets, clear actions, cancel option
// Design: iOS-style action sheet pattern
```

**SwipeableCard** - Gesture-enabled cards
```jsx
// Purpose: Cards with swipe actions (delete, archive, etc.)
// Features: Smooth gesture response, action reveals
// Mobile: Natural swipe interactions
```

#### 6. Data Display (`/components/data/`)

**DataTable** - Responsive table component
```jsx
// Purpose: Display tabular data across devices
// Features: Horizontal scroll (mobile), full table (desktop)
// Mobile: Card-based stacking option
```

**DataList** - Mobile-optimized list display
```jsx
// Purpose: List of items with actions
// Features: Avatar, title, subtitle, trailing actions
// Mobile: Touch-friendly, swipe actions
```

**EmptyState** - No data placeholder
```jsx
// Purpose: Friendly empty states with actions
// Features: Illustration, title, description, CTA
// Design: Encouraging and helpful messaging
```

## 🏗️ Complete File Structure

Generate this exact file structure with placeholder files (comments only, 2-3 lines each):

```
src/
├── components/
│   ├── ui/                      # Atoms - shadcn/ui base components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── card.tsx
│   │   ├── badge.tsx
│   │   ├── avatar.tsx
│   │   ├── checkbox.tsx
│   │   ├── radio-group.tsx
│   │   ├── select.tsx
│   │   ├── switch.tsx
│   │   ├── textarea.tsx
│   │   ├── toast.tsx
│   │   ├── tooltip.tsx
│   │   ├── dialog.tsx
│   │   ├── sheet.tsx
│   │   ├── dropdown-menu.tsx
│   │   ├── popover.tsx
│   │   ├── tabs.tsx
│   │   ├── accordion.tsx
│   │   ├── slider.tsx
│   │   ├── progress.tsx
│   │   ├── separator.tsx
│   │   ├── skeleton.tsx
│   │   └── index.ts
│   ├── compound/                # Molecules - combinations of atoms
│   │   ├── form-field.tsx
│   │   ├── search-bar.tsx
│   │   ├── menu-item.tsx
│   │   ├── list-item.tsx
│   │   ├── stat-item.tsx
│   │   ├── feature-item.tsx
│   │   └── index.ts
│   ├── blocks/                  # Organisms - complex UI sections
│   │   ├── navigation-bar.tsx
│   │   ├── product-card.tsx
│   │   ├── feature-section.tsx
│   │   ├── stats-section.tsx
│   │   ├── testimonial-section.tsx
│   │   ├── pricing-section.tsx
│   │   ├── contact-form.tsx
│   │   ├── user-profile.tsx
│   │   ├── data-table.tsx
│   │   └── index.ts
│   ├── layout/                  # Templates - page structures
│   │   ├── app-shell.tsx
│   │   ├── auth-layout.tsx
│   │   ├── dashboard-layout.tsx
│   │   ├── marketing-layout.tsx
│   │   ├── mobile-bottom-nav.tsx
│   │   ├── desktop-sidebar.tsx
│   │   ├── top-app-bar.tsx
│   │   └── index.ts
│   ├── navigation/              # Navigation-specific components
│   │   ├── bottom-tab-bar.tsx
│   │   ├── slide-out-drawer.tsx
│   │   ├── breadcrumbs.tsx
│   │   ├── back-button.tsx
│   │   └── index.ts
│   ├── forms/                   # Form-specific components
│   │   ├── one-field-form.tsx
│   │   ├── multi-step-form.tsx
│   │   ├── form-wizard.tsx
│   │   ├── login-form.tsx
│   │   ├── register-form.tsx
│   │   └── index.ts
│   ├── cards/                   # Card variations
│   │   ├── product-card.tsx
│   │   ├── info-card.tsx
│   │   ├── stats-card.tsx
│   │   ├── pricing-card.tsx
│   │   └── index.ts
│   ├── interactive/             # Gesture and interactive components
│   │   ├── bottom-sheet.tsx
│   │   ├── action-sheet.tsx
│   │   ├── swipeable-card.tsx
│   │   ├── pull-to-refresh.tsx
│   │   └── index.ts
│   ├── data/                    # Data display components
│   │   ├── data-table.tsx
│   │   ├── data-list.tsx
│   │   ├── empty-state.tsx
│   │   ├── loading-state.tsx
│   │   └── index.ts
│   └── pages/                   # Page implementations
│       ├── home-page.tsx
│       ├── dashboard-page.tsx
│       ├── profile-page.tsx
│       ├── settings-page.tsx
│       ├── login-page.tsx
│       ├── register-page.tsx
│       └── index.ts
├── hooks/                       # Custom React hooks
│   ├── use-mobile.tsx
│   ├── use-bottom-sheet.tsx
│   ├── use-local-storage.tsx
│   ├── use-debounce.tsx
│   ├── use-intersection-observer.tsx
│   ├── use-gesture.tsx
│   └── index.ts
├── stores/                      # Zustand state management
│   ├── user-store.ts
│   ├── ui-store.ts
│   ├── products-store.ts
│   ├── cart-store.ts
│   ├── navigation-store.ts
│   └── index.ts
├── services/                    # API services layer
│   ├── api.ts
│   ├── auth-service.ts
│   ├── user-service.ts
│   ├── products-service.ts
│   ├── orders-service.ts
│   └── index.ts
├── data/                        # Mock data for development
│   ├── users.ts
│   ├── products.ts
│   ├── orders.ts
│   ├── categories.ts
│   ├── schemas.ts
│   └── index.ts
├── types/                       # TypeScript type definitions
│   ├── auth.ts
│   ├── user.ts
│   ├── product.ts
│   ├── order.ts
│   ├── api.ts
│   └── index.ts
├── lib/                         # Utility functions
│   ├── utils.ts
│   ├── cn.ts
│   ├── formatters.ts
│   ├── validators.ts
│   ├── constants.ts
│   └── auth.ts
├── styles/                      # Global styles
│   ├── globals.css
│   ├── components.css
│   └── mobile.css
└── app/                         # App routing (if using Next.js App Router)
    ├── layout.tsx
    ├── page.tsx
    ├── dashboard/
    │   └── page.tsx
    ├── profile/
    │   └── page.tsx
    └── auth/
        ├── login/
        │   └── page.tsx
        └── register/
            └── page.tsx
```

## 📊 Mock Data Architecture

Create a centralized mock data system that mirrors real database schemas:

### Data Schema Structure (`/data/schemas.ts`)
```typescript
// Central schema definitions that match future database structure
// Includes relationships, validation rules, and type definitions
// Designed for easy migration to Supabase/Firebase/Appwrite
```

### Mock Data Files
- **users.ts**: User profiles, preferences, authentication data
- **products.ts**: Product catalog with categories, pricing, inventory
- **orders.ts**: Order history, cart items, payment information
- **categories.ts**: Product categorization and taxonomy

### Service Layer Pattern
```typescript
// services/products-service.ts
// Mock implementation that matches real API structure
// Easy swap from mock data to actual API calls
// Consistent interface for components to consume
```

## 📱 PWA Configuration

### Required PWA Files

Create these files in `/public/`:

**manifest.json**
```json
{
  "name": "[Your App Name]",
  "short_name": "[Short Name]",
  "description": "[App Description]",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#[Your Primary Color]",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "shortcuts": [
    {
      "name": "Dashboard",
      "short_name": "Dashboard",
      "description": "Open app dashboard",
      "url": "/dashboard",
      "icons": [{ "src": "/icons/dashboard-96.png", "sizes": "96x96" }]
    }
  ]
}
```

**Required Icon Structure:**
```
public/
├── icons/
│   ├── icon-192.png          # 192x192 app icon
│   ├── icon-512.png          # 512x512 app icon
│   ├── icon-maskable-192.png # 192x192 maskable
│   ├── icon-maskable-512.png # 512x512 maskable
│   ├── apple-touch-icon.png  # 180x180 iOS icon
│   └── favicon.ico           # 32x32 favicon
├── manifest.json
└── sw.js                     # Service worker (if needed)
```

### Mobile Optimizations

**Dynamic Viewport Height Setup:**
```javascript
// utils/viewport.ts
// Set up dynamic viewport height that works with mobile browsers
// Handles address bar show/hide behavior properly
// Creates CSS custom property --vh for reliable mobile layouts
```

**Touch Optimizations:**
```css
/* Mobile-first touch optimizations */
.touch-action-pan-y { touch-action: pan-y; }
.touch-action-manipulation { touch-action: manipulation; }
.user-select-none { user-select: none; }
.webkit-tap-highlight-transparent { -webkit-tap-highlight-color: transparent; }
```

## 🔧 Development Setup

### Essential Dependencies
Install these packages:
```bash
# Core framework
npm install react react-dom typescript

# Routing and navigation
npm install react-router-dom

# Styling and UI
npm install tailwindcss @tailwindcss/typography
npm install lucide-react
npm install class-variance-authority clsx tailwind-merge

# State management
npm install zustand

# Forms and validation
npm install react-hook-form @hookform/resolvers zod

# Development tools
npm install @types/react @types/react-dom
npm install eslint @typescript-eslint/eslint-plugin
npm install prettier prettier-plugin-tailwindcss
```

### Tailwind Configuration
```javascript
// tailwind.config.js
// Configure with design tokens, mobile-first breakpoints
// Include container queries plugin for component-based responsive design
// Set up custom utilities for touch interactions and mobile optimizations
```

### Environment Configuration
```bash
# .env.local
# Set up development environment variables
# Include mock API endpoints that match production structure
# Configure for easy switching between mock and real APIs
```

## 📝 Project LLMs.txt Generation

Create this file in the project root to guide future AI interactions:

**project-llms.txt**
```
# [Project Name] - Mobile-First Design System

## Project Overview
[Brief description of the app and its purpose]

## Architecture Decisions
- Mobile-first responsive design with container queries
- Atomic design component methodology (atoms → molecules → organisms → templates → pages)
- Zustand for state management
- Mock data architecture mirroring real database schemas
- PWA-ready with proper manifest and offline capabilities

## Development Patterns
- TypeScript for all components and services
- Tailwind CSS with custom design tokens
- shadcn/ui as base component library
- React Hook Form for form management
- React Router for client-side routing

## File Organization
- `/components/ui/` - Base atomic components (shadcn/ui)
- `/components/compound/` - Molecule components (combinations of atoms)
- `/components/blocks/` - Organism components (complex UI sections)
- `/components/layout/` - Template components (page structures)
- `/components/pages/` - Page implementations

## Mobile Optimizations
- Dynamic viewport height handling for mobile browsers
- Touch-first interaction design (44px minimum touch targets)
- Bottom navigation for mobile, sidebar for desktop
- Progressive enhancement approach

## Data Strategy
- Mock data in `/data/` folder during development
- Service layer abstraction in `/services/`
- Easy migration path to real APIs (Supabase/Firebase/Appwrite)
- Centralized type definitions in `/types/`

## Next Steps for Development
1. Implement authentication flow
2. Connect real API endpoints
3. Add data persistence
4. Implement offline functionality
5. Optimize performance and bundle size
6. Add analytics and monitoring

## Component Guidelines
- Follow atomic design principles
- Mobile-first responsive design
- Accessibility standards (WCAG 2.1 AA)
- TypeScript interfaces for all props
- Consistent naming conventions
- Performance-first approach

## Design System
- Colors: [Your chosen color palette]
- Typography: Mobile-first scale with desktop enhancement
- Spacing: 4px base unit system
- Border radius: Consistent scale (sm: 6px, md: 8px, lg: 12px)
- Shadows: Subtle and consistent across components

For adding new features or components, follow the established patterns and maintain consistency with the mobile-first approach.
```

## 🚀 Implementation Instructions

1. **Start with the customization section** - Replace all placeholder values with your specific project details

2. **Generate the complete file structure** - Create all folders and placeholder files as specified

3. **Begin with core atoms** - Implement button, input, card components first

4. **Build up systematically** - Follow atomic design progression (atoms → molecules → organisms → templates → pages)

5. **Test on mobile devices** - Verify touch interactions and responsive behavior throughout development

6. **Optimize performance** - Implement lazy loading, code splitting, and PWA features

This design system prompt will create a solid foundation for any mobile-first web application, providing all the necessary components, patterns, and optimizations for a modern, scalable user interface.

---

**Note**: After using this prompt with your AI builder, you'll have a complete, production-ready design system that works beautifully across all devices and provides a solid foundation for rapid application development.
