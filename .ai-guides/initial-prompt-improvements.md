/**
 * Initial Prompt Improvements
 * 
 * Purpose: Enhance the first prompt given to lovable.dev to establish project vision and design system
 * 
 * Current challenges:
 * - No explicit instructions for placeholder file format (comments only, 3-5 lines)
 * - Lacks atomic design terminology (atoms, molecules, organisms)
 * - Missing clear guidance on interface boundaries between UI and data
 * - Overwhelming design focus works well, but could be more strategic
 * - No explicit section about file structure and placeholder generation
 * - Needs clearer data architecture guidance for later Supabase integration
 * 
 * Before implementation, need:
 * - Example of current outcomes from initial prompt
 * - Latest version of initial prompt with any recent modifications
 * - Specific pain points experienced with current prompt results
 * 
 * v2 Updates (2025-05-27):
 * - Analyzed both K-beauty specific prompt and generic template
 * - Both successfully establish comprehensive design systems
 * - Intentional overwhelming design focus works as strategy
 * - Will preserve ALL original content while adding new sections
 * - Adding atomic design, data architecture, and placeholder file guidelines
 */

# Mobile-First Design System: Comprehensive Guide

## 🔍 Project Overview

[PROJECT_NAME] is a [brief description of app purpose] for [target audience] that features a [UX style reference] to [core value proposition] with a [theme style description] built around a [color palette description].

Important: This is where you'll define your project's specific details. All design elements (especially colors, typography, and component styling) should be customized based on this description. The design system will automatically adapt its color palette, styling patterns, and UX approach based on what you specify here.

## 📱 Core Principles & Philosophy

### Foundation: Mobile-First, Touch-First, Human-First

Our design system is built on three interconnected pillars that guide every decision:

1. **Mobile-First Design**
   - Design begins at 320px width and scales upward
   - Every component must work flawlessly on mobile before desktop considerations
   - Progressive enhancement rather than graceful degradation
   - Performance is a feature, not an afterthought

2. **Touch-First Interaction**
   - All interactive elements are designed for finger input first
   - Touch targets maintain minimum 44px × 44px (11rem) dimensions
   - Interactive elements positioned within natural thumb zones
   - Primary actions always within easy reach of one-handed operation

3. **Human-First Experience**
   - Design for human cognitive and perceptual limitations
   - Reduce cognitive load through consistent patterns
   - Embrace accessibility as a fundamental requirement
   - Accommodate real-world usage conditions (poor lighting, distractions, movement)

### Core Design Values

- **Consistency Over Creativity**: Predictable patterns build user confidence
- **Clarity Over Cleverness**: Users should never wonder what something does
- **Accessibility Over Aesthetics**: Beautiful design that works for everyone
- **Performance Over Polish**: Fast, responsive interactions trump perfect visuals
- **Context Over Control**: Adapt to user's environment and needs

### Accessibility Fundamentals

Accessibility is embedded in our design DNA, not added later:

- **Perceivable**: All information must be perceivable by all users
  - Color contrast ratio minimum 4.5:1 for text (WCAG AA)
  - Non-text contrast minimum 3:1 for interactive elements
  - Text scales to 200% without loss of content or function
  - All content available to screen readers

- **Operable**: All functionality must be operable by all users
  - Keyboard navigable with visible focus states
  - Touch targets minimum 44×44px with adequate spacing
  - No time-dependent interactions (or alternatives provided)
  - No content that can trigger seizures or physical reactions

- **Understandable**: All information must be understandable by all users
  - Consistent navigation and interaction patterns
  - Predictable behaviors when interacting with components
  - Error prevention and clear error recovery
  - Context-aware help and guidance

- **Robust**: All content must be compatible with assistive technologies
  - Semantic HTML as foundation
  - ARIA roles and attributes where native semantics insufficient
  - Tested with screen readers and assistive technologies

## 🎨 Visual Language

### Typography System

Typography creates clear information hierarchy and readability across all devices.

#### Font Scale

| Role | Mobile | Desktop | Tailwind Class | Use Case |
|------|--------|---------|----------------|----------|
| Display XL | 36px/40px | 72px/80px | `text-4xl md:text-7xl` | Hero headlines, marketing |
| Display L | 30px/36px | 60px/72px | `text-3xl md:text-6xl` | Major section headers |
| Display M | 24px/32px | 48px/56px | `text-2xl md:text-5xl` | Feature headlines |
| H1 | 24px/32px | 36px/44px | `text-2xl md:text-4xl` | Page titles |
| H2 | 20px/28px | 30px/38px | `text-xl md:text-3xl` | Major section headers |
| H3 | 18px/26px | 24px/32px | `text-lg md:text-2xl` | Section headers |
| H4 | 16px/24px | 20px/28px | `text-base md:text-xl` | Subsection headers |
| Body Large | 16px/24px | 18px/28px | `text-base md:text-lg` | Featured content, leads |
| Body | 14px/22px | 16px/24px | `text-sm md:text-base` | Primary content |
| Body Small | 13px/20px | 14px/22px | `text-xs md:text-sm` | Secondary content |
| Caption | 12px/16px | 12px/16px | `text-xs` | Labels, metadata |
| Micro | 11px/14px | 11px/14px | `text-[11px] leading-[14px]` | Legal, fine print |

#### Font Weights

| Weight | Value | Tailwind Class | Usage |
|--------|-------|----------------|-------|
| Bold | 700 | `font-bold` | Headings, emphasis, CTAs |
| Semibold | 600 | `font-semibold` | Subheadings, selected state |
| Medium | 500 | `font-medium` | Labels, important text |
| Regular | 400 | `font-normal` | Body text, default |
| Light | 300 | `font-light` | Large display text, subtle UI |

#### Typography Implementation Guidelines

- **Responsive Adaptation**
  - Text scales proportionally between breakpoints
  - Line heights remain comfortable at all sizes
  - Font weights may increase on smaller screens for legibility

- **Hierarchy Rules**
  - Maximum 3 levels of heading on any single view
  - Maintain consistent scaling ratio (1.2× mobile, 1.25× desktop)
  - Skip levels (e.g., H1 to H3) only when visually justified

- **Readability Optimization**
  - Line length: 45-75 characters (mobile), 65-85 characters (desktop)
  - Adequate spacing between paragraphs (1em minimum)
  - Avoid justified text; use left-aligned for most content
  - Sufficient contrast between text and background

- **Text Alignment Patterns**
  - Left-aligned: Default for most content (natural reading flow)
  - Center-aligned: Used for short headlines, features, empty states
  - Right-aligned: Only for numerical data in tables or specific UI elements

### Color System

Our color system creates visual hierarchy, conveys meaning, and reinforces brand identity while ensuring accessibility.

Note: The color values below are neutral placeholders and should be replaced with your project's actual color palette as defined in your project overview (e.g., "Pink/Red palette" or "forest green theme"). These HSL/Hex values are only starting points.

#### Primary Color Palette

| Role | HSL | Hex | Tailwind Variable | Usage |
|------|-----|-----|-------------------|-------|
| Primary | 221 83% 53% | #3b82f6 | `hsl(var(--primary))` | Brand, CTAs, active states |
| Primary Hover | 221 83% 47% | #2563eb | `hsl(var(--primary-hover))` | Hover states for primary |
| Primary Light | 221 83% 93% | #dbeafe | `hsl(var(--primary-light))` | Backgrounds, selected states |
| Secondary | 217 91% 60% | #4f46e5 | `hsl(var(--secondary))` | Accents, secondary actions |
| Tertiary | 271 91% 65% | #c084fc | `hsl(var(--tertiary))` | Highlights, gradient endpoints |

#### Semantic Color Palette

| Role | Usage | Notes |
|------|-------|-------|
| Success | Positive outcomes, completion | Typically a green shade, easily distinguishable from primary |
| Warning | Caution, pending states | Typically an amber/yellow shade, high visibility |
| Error | Errors, destructive actions | Typically a red shade, clearly communicates importance |
| Info | Information, help, neutral alerts | Often a blue shade, differentiated from primary |

All colors should be adjusted to match your project's palette while maintaining appropriate contrast ratios and accessibility standards.

#### Neutral Color Palette

| Role | Usage | Notes |
|------|-------|-------|
| Background | App background | Main application background, typically light in light mode, dark in dark mode |
| Foreground | Primary text | Main text color, must have high contrast with background |
| Card | Card backgrounds | Container elements, often same as background or slightly differentiated |
| Card Foreground | Card text | Text on cards, typically same as main foreground |
| Muted | Subtle backgrounds | Secondary surfaces, slightly contrasted from main background |
| Muted Foreground | Secondary text | De-emphasized text, still meeting accessibility standards |
| Accent | Subtle highlights | For minor emphasis, slightly contrasted from background |
| Border | Borders, dividers | Subtle separation between elements |
| Input | Form controls | Borders and backgrounds for form elements |
| Ring | Focus indicators | Visible outlines for keyboard navigation, matching primary or a variant |

These neutral colors form the foundation of your interface and should be customized to match your brand while maintaining readability and proper contrast.

#### Brand Gradients

| Gradient | Definition | Usage |
|----------|------------|-------|
| Primary Gradient | `bg-gradient-to-r from-primary to-secondary` | CTAs, feature highlighting |
| Hero Gradient | `bg-gradient-to-br from-primary via-secondary to-tertiary` | Heroes, marketing sections |
| Subtle Gradient | `bg-gradient-to-r from-background to-muted` | Section backgrounds, cards |

Gradients should be crafted to match your project's color palette. The examples above use the default variables, but should be adjusted to use your brand colors.

#### Color Implementation Guidelines

- **Accessibility First**
  - All text must maintain 4.5:1 contrast ratio with its background
  - Interactive elements must maintain 3:1 contrast with surroundings
  - Never use color alone to convey meaning; pair with text, icons, or patterns
  - Test color combinations with color blindness simulators

- **Color Meaning Consistency**
  - Primary: Brand identity, main actions, current state
  - Success: Completed actions, positive outcomes, approval
  - Warning: Pending actions, caution required, important notes
  - Error: Failed actions, critical issues, destructive operations
  - Info: Neutral alerts, general information, help

- **Gradient Usage Rules**
  - Use gradients sparingly for emphasis
  - Maintain adequate contrast throughout gradient transitions
  - Ensure text remains readable across entire gradient
  - Apply consistently to similar UI elements

### Spacing System

Our spacing system creates rhythm, hierarchy, and proper density across all screen sizes.

#### Base Unit

The foundational spacing unit is 4px (0.25rem in Tailwind). All spacing values are multiples of this base unit to ensure consistency.

#### Spacing Scale

| Scale | Value | Tailwind | Description | Usage |
|-------|-------|----------|-------------|-------|
| 2xs | 2px (0.125rem) | `space-2xs` | Micro spacing | Icon internals, hairlines |
| xs | 4px (0.25rem) | `space-xs` | Extra small | Tight internal component spacing |
| sm | 8px (0.5rem) | `space-sm` | Small | Close elements, icon to text |
| md | 12px (0.75rem) | `space-md` | Medium | Related elements, form controls |
| base | 16px (1rem) | `space-base` | Base unit | Standard component spacing |
| lg | 24px (1.5rem) | `space-lg` | Large | Section padding, card spacing |
| xl | 32px (2rem) | `space-xl` | Extra large | Major section divisions |
| 2xl | 48px (3rem) | `space-2xl` | 2× extra large | Page sections, major blocks |
| 3xl | 64px (4rem) | `space-3xl` | 3× extra large | Hero sections, major landmarks |
| 4xl | 96px (6rem) | `space-4xl` | 4× extra large | Page separators, major landmarks |

#### Spacing Application Patterns

| Context | Mobile | Tablet | Desktop | Tailwind Class |
|---------|--------|--------|---------|----------------|
| Page container padding | 16px | 24px | 32px | `p-4 md:p-6 lg:p-8` |
| Card padding | 16px | 24px | 24px | `p-4 md:p-6` |
| Section spacing | 32px | 48px | 64px | `space-y-8 md:space-y-12 lg:space-y-16` |
| Form field groups | 16px | 24px | 24px | `space-y-4 md:space-y-6` |
| Button padding | 12px 16px | 12px 20px | 12px 24px | `px-4 py-3 md:px-5 lg:px-6` |
| Icon + text spacing | 8px | 8px | 8px | `gap-2` |
| List item spacing | 12px | 16px | 16px | `space-y-3 md:space-y-4` |

#### Responsive Spacing Guidelines

- **Mobile Density**
  - Tighter spacing for efficient screen usage
  - Touch targets must maintain minimum 44×44px
  - Adequate separation between interactive elements (8px minimum)

- **Desktop Expansion**
  - More generous whitespace as screen size increases
  - Max width constraints to prevent excessive line lengths
  - Maintain consistent spacing ratios between elements

## 📐 Layout Foundations

### Grid System

Our grid system provides structural consistency while adapting fluidly across devices.

#### Base Grid

- **Columns**: 4 (mobile), 8 (tablet), 12 (desktop)
- **Gutters**: 16px (mobile), 24px (tablet), 32px (desktop)
- **Margins**: 16px (mobile), 32px (tablet), 64px (desktop)

#### Container Widths

| Container | Width | Tailwind Class | Usage |
|-----------|-------|----------------|-------|
| Full | 100% | `container` | Full-width layouts |
| Standard | 1280px max | `container max-w-screen-xl` | Default page container |
| Narrow | 768px max | `container max-w-screen-md` | Content-focused pages |
| X-Narrow | 640px max | `container max-w-screen-sm` | Forms, focused tasks |
| Wide | 1536px max | `container max-w-screen-2xl` | Data-heavy dashboards |

#### Common Layout Patterns

| Pattern | Mobile | Desktop | Tailwind Implementation |
|---------|--------|---------|-------------------------|
| Single column | Full width | 768px centered | `max-w-screen-md mx-auto` |
| Two column | Stack | Side-by-side | `grid grid-cols-1 md:grid-cols-2 gap-4 md:gap-6` |
| Sidebar + Content | Stack | 1:3 ratio | `grid grid-cols-1 lg:grid-cols-4 gap-6 [&>*:first-child]:lg:col-span-1 [&>*:last-child]:lg:col-span-3` |
| Card grid | 1 column | 3-4 columns | `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 md:gap-6` |
| Dashboard | Stack | Multi-zone | `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6 [&>*:first-child]:col-span-full [&>*.wide]:md:col-span-2` |

#### Layout Implementation Guidelines

- **Responsive Behavior**
  - Mobile layouts stack vertically (single column)
  - Tablet begins introducing multi-column where appropriate
  - Desktop optimizes for horizontal space usage
  - Element order can change between mobile and desktop for optimal experience

- **Containment Patterns**
  - Page content always within containers with consistent padding
  - Cards maintain uniform padding within the same view
  - Related elements grouped within common containers
  - Clear visual boundaries between major sections

- **Space Distribution**
  - Use flexbox `justify-between` for header elements with actions
  - Apply consistent gap spacing with grid and flexbox layouts
  - Maintain proportional spacing ratios across breakpoints
  - Use auto margins strategically for alignment and separation

### Responsive Breakpoints

Our breakpoints are strategically chosen to accommodate common device sizes and usage patterns.

#### Breakpoint Scale

| Breakpoint | Width | Tailwind Prefix | Target Devices |
|------------|-------|-----------------|----------------|
| Default | 0-639px | (no prefix) | Mobile portrait |
| sm | 640px+ | `sm:` | Mobile landscape, small tablets |
| md | 768px+ | `md:` | Tablets, narrow browsers |
| lg | 1024px+ | `lg:` | Laptops, desktops |
| xl | 1280px+ | `xl:` | Large desktops, mid-size monitors |
| 2xl | 1536px+ | `2xl:` | Large monitors, ultra-wide displays |

#### Dynamic Viewport Height (DVH)

Mobile browsers have a unique challenge with viewport height due to address bars and navigation elements that appear/disappear. The `100vh` CSS value often causes issues on mobile, with content either being cut off or causing unwanted scrolling.

**The DVH Solution:**

```javascript
// Set a custom property for viewport height that adjusts to real visible height
function setDynamicVH() {
  // Get the actual visible height
  const vh = window.innerHeight * 0.01;
  // Set it as a CSS custom property
  document.documentElement.style.setProperty('--vh', `${vh}px`);
}

// Run on load and resize
window.addEventListener('resize', setDynamicVH);
window.addEventListener('orientationchange', setDynamicVH);
setDynamicVH();

// In CSS, use this custom property
// .full-height {
//   height: 100vh; /* Fallback */
//   height: calc(var(--vh, 1vh) * 100); /* Dynamic viewport height */
// }
```

**Tailwind Implementation:**

```javascript
// tailwind.config.js
const plugin = require('tailwindcss/plugin');

module.exports = {
  // ... other configuration
  plugins: [
    plugin(function({ addUtilities }) {
      addUtilities({
        '.h-dvh': {
          height: 'calc(var(--vh, 1vh) * 100)',
        },
        '.min-h-dvh': {
          'min-height': 'calc(var(--vh, 1vh) * 100)',
        },
        '.max-h-dvh': {
          'max-height': 'calc(var(--vh, 1vh) * 100)',
        },
      });
    }),
  ],
}
```

**Usage in Components:**

```jsx
// Instead of h-screen or min-h-screen, use:
<div className="h-dvh">Full viewport height, even on mobile browsers</div>
<div className="min-h-dvh">At least full viewport height</div>

// For modals and full-page layouts:
<div className="fixed inset-0 min-h-dvh overflow-y-auto">
  {/* Content that properly adapts to mobile browser chrome */}
</div>
```

#### Responsive Design Principles

- **Mobile-First Default**
  - Base CSS applies to smallest screens
  - Use `min-width` media queries to enhance for larger screens
  - Never assume desktop-first and scale down

- **Major Layout Shifts**
  - 768px (md): Navigation changes from bottom to top
  - 768px (md): Begin introducing multi-column layouts
  - 1024px (lg): Optimize for desktop interaction patterns
  - 1280px (xl): Take advantage of additional screen real estate

- **Consistent Behavior**
  - Components maintain proportional sizing across breakpoints
  - Spacing scales proportionally with screen size
  - Touch targets remain accessible at all sizes
  - Visual hierarchy preserved across all breakpoints

### Navigation Patterns

Navigation adapts contextually to device size, maintaining intuitive access to key destinations.

#### Mobile Navigation (0-767px)

- **Bottom Tab Bar**
  - Fixed to bottom of viewport
  - 5 items maximum (thumb reach limitation)
  - Icons with optional short labels
  - Active state clearly indicated
  - Safe area inset padding for notched devices

- **Header (App Bar)**
  - Page title centered
  - Back button when applicable (left)
  - Actions positioned on right
  - Condensed to maximize content space
  - Sticky positioning for long content

#### Desktop Navigation (768px+)

- **Top Navigation Bar**
  - Full application width
  - Brand on left
  - Primary navigation centered or right-aligned
  - User account/profile actions on far right
  - Sticky positioning for long content

- **Breadcrumbs**
  - For complex hierarchical navigation
  - Shows current location context
  - Provides quick return to parent sections
  - Truncates on smaller screens when necessary
  - Optional on mobile (can hide below md: breakpoint)

## 🧩 Component System

### Atomic Design Methodology

Our component system follows the atomic design methodology, creating a scalable and consistent UI from the smallest building blocks to complete pages:

1. **Atoms**: Basic UI elements that can't be broken down further
   - Buttons, inputs, labels, icons, badges
   - Form the building blocks for all other components
   - Highly reusable and consistent across the application

2. **Molecules**: Simple combinations of atoms that form functional groups
   - Form fields (label + input + error message)
   - Search bars (input + button)
   - Card headers (title + description + actions)
   - Navigation items (icon + label)

3. **Organisms**: Complex UI sections composed of molecules and atoms
   - Navigation bars
   - Forms
   - Product cards
   - Header sections
   - Comment threads

4. **Templates**: Page-level structures with placeholders for content
   - Layout grids
   - Page frameworks
   - Screen templates with consistent zones

5. **Pages**: Specific instances of templates with real content
   - Home page
   - Product page
   - Settings page
   - Profile page

### Core Components

Our component system provides consistent, accessible, and adaptable UI building blocks.

#### Button

The primary interaction element, with consistent sizing, styling and behaviors.

```jsx
<Button 
  variant="primary" // or "secondary", "outline", "ghost", "link", "destructive"
  size="md" // or "sm", "lg"
  icon={<Icon />} // optional leading icon
  iconPosition="left" // or "right"
  disabled={false}
  loading={false}
  onClick={() => {}}
>
  Button Text
</Button>
```

**Button Specifications:**

| Property | Small | Medium | Large | Tailwind Classes |
|----------|-------|--------|-------|------------------|
| Height | 32px | 40px | 48px | `h-8 h-10 h-12` |
| Padding X | 12px | 16px | 20px | `px-3 px-4 px-5` |
| Font Size | 14px | 14px | 16px | `text-sm text-sm text-base` |
| Border Radius | 6px | 8px | 10px | `rounded-md rounded-lg rounded-xl` |
| Icon Size | 16px | 18px | 20px | `w-4 h-4 w-4.5 h-4.5 w-5 h-5` |
| Min Width | 64px | 80px | 96px | `min-w-[64px] min-w-[80px] min-w-[96px]` |

**Button Variants:**

| Variant | Default | Hover | Active | Disabled |
|---------|---------|-------|--------|----------|
| Primary | bg-primary text-white | bg-primary-hover | bg-primary-active | opacity-50 |
| Secondary | bg-secondary text-white | bg-secondary-hover | bg-secondary-active | opacity-50 |
| Outline | border border-input bg-transparent | bg-accent | bg-accent/80 | opacity-50 |
| Ghost | bg-transparent | bg-accent | bg-accent/80 | opacity-50 |
| Destructive | bg-destructive text-white | bg-destructive/90 | bg-destructive/80 | opacity-50 |
| Link | text-primary underline | text-primary-hover | text-primary-active | opacity-50 |

**Button Guidelines:**

- Use only one primary button per view or form
- Maintain consistent verb-noun labeling (e.g., "Save Changes", not just "Save")
- Position primary actions on right, secondary/cancel on left
- Include loading states for asynchronous operations
- Always provide keyboard focus styles and ARIA attributes
- For icon-only buttons, include aria-label and tooltip

#### Card

Container for related content with consistent styling and organization.

```jsx
<Card>
  <CardHeader>
    <CardTitle>Card Title</CardTitle>
    <CardDescription>Optional description text</CardDescription>
  </CardHeader>
  <CardContent>
    {/* Main content */}
  </CardContent>
  <CardFooter>
    {/* Optional footer actions */}
  </CardFooter>
</Card>
```

**Card Specifications:**

| Property | Value | Tailwind Classes |
|----------|-------|------------------|
| Padding | 16px (mobile), 24px (tablet+) | `p-4 md:p-6` |
| Border Radius | 12px | `rounded-xl` |
| Border | 1px solid border color | `border border-border` |
| Shadow | Subtle shadow | `shadow-sm` |
| Background | Card background | `bg-card` |
| Header Bottom Margin | 16px | `mb-4` |
| Between Cards | 16px (mobile), 24px (tablet+) | `gap-4 md:gap-6` |

**Card Variants:**

- **Standard**: Default styling with full padding
- **Compact**: Reduced padding (`p-3 md:p-4`) for dense UIs
- **Interactive**: With hover state and cursor pointer
- **Bordered**: More prominent border for emphasis
- **Elevated**: Stronger shadow for floating appearance

**Card Guidelines:**

- Use consistent spacing within card content (usually 16px between elements)
- Maintain semantic structure (header, content, footer)
- For interactive cards, ensure entire card is clickable
- Group related information within cards
- Use consistent heading hierarchy within cards
- Avoid deeply nested cards (maximum one level of nesting)

#### Input

Text input fields with consistent styling, states, and behaviors.

```jsx
<div className="space-y-2">
  <Label htmlFor="email">Email Address</Label>
  <Input 
    id="email"
    type="email"
    placeholder="Enter your email"
    disabled={false}
    error={errors.email}
    size="md" // or "sm", "lg"
    prefix={<Icon />} // Optional leading content
    suffix={<Button variant="ghost" size="sm">Clear</Button>} // Optional trailing content
  />
  {errors.email && (
    <p className="text-sm text-destructive">{errors.email}</p>
  )}
</div>
```

**Input Specifications:**

| Property | Small | Medium | Large | Tailwind Classes |
|----------|-------|--------|-------|------------------|
| Height | 32px | 40px | 48px | `h-8 h-10 h-12` |
| Padding X | 12px | 16px | 16px | `px-3 px-4 px-4` |
| Font Size | 14px | 14px | 16px | `text-sm text-sm text-base` |
| Border Radius | 6px | 8px | 8px | `rounded-md rounded-lg rounded-lg` |
| Border | 1px solid | 1px solid | 1px solid | `border border-input` |

**Input States:**

| State | Styling | Tailwind Classes |
|-------|---------|------------------|
| Default | Standard border | `border border-input` |
| Focus | Primary ring | `focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2` |
| Disabled | Muted appearance | `opacity-50 cursor-not-allowed` |
| Error | Red border | `border-destructive focus-visible:ring-destructive` |
| With Prefix | Space for icon | `pl-10` (with positioned icon) |
| With Suffix | Space for action | `pr-10` (with positioned element) |

**Input Guidelines:**

- Always pair with descriptive label
- Use placeholder text as suggestion, not as label
- Show validation errors below the input
- Maintain consistent height within a form
- Use appropriate input types (email, tel, number, etc.)
- Include autocomplete attributes for better UX
- Ensure proper contrast for entered text

### Form Patterns

Consistent approaches to form design, validation, and interaction.

#### Form Layout

```jsx
<Form onSubmit={handleSubmit}>
  <Card>
    <CardHeader>
      <CardTitle>Form Title</CardTitle>
      <CardDescription>Optional form description text</CardDescription>
    </CardHeader>
    <CardContent className="space-y-6">
      {/* Form sections */}
      <div className="space-y-4">
        <h3 className="text-lg font-medium">Section Title</h3>
        <div className="space-y-4">
          {/* Form fields */}
          <FormField
            label="Field Label"
            htmlFor="fieldId"
            error={errors.field}
            description="Optional help text for this field."
          >
            <Input id="fieldId" />
          </FormField>
        </div>
      </div>
    </CardContent>
    <CardFooter className="flex justify-between">
      <Button variant="outline" type="button">Cancel</Button>
      <Button type="submit" loading={isSubmitting}>Submit</Button>
    </CardFooter>
  </Card>
</Form>
```

**Form Layout Specifications:**

| Property | Value | Tailwind Classes |
|----------|-------|------------------|
| Between Fields | 16px | `space-y-4` |
| Between Sections | 24px | `space-y-6` |
| Label to Input | 8px | `space-y-2` |
| Field to Help Text | 4px | `space-y-1` |
| Section Title | 18px/Medium | `text-lg font-medium` |
| Max Form Width | 640px | `max-w-screen-sm` |

**Form Patterns:**

- **Single Column**: Default for mobile and most forms
- **Two Column**: For related fields or compact desktop layouts
- **Sectioned**: Logical grouping with headings for complex forms
- **Wizard/Steps**: Complex processes broken into sequential steps
- **Inline Validation**: Real-time feedback as users complete fields

## 📊 Data Architecture

### Modular Data Strategy

Our data architecture follows a modular approach with clean separation between UI and data sources:

1. **Type Definitions**: Centralized TypeScript interfaces in `/types` folder
   - Shared across the entire application
   - Single source of truth for data structures
   - Carefully versioned and commented

2. **Store Layer**: Zustand stores in `/stores` folder
   - State management abstraction
   - UI components only interact with stores, never directly with services
   - Handles loading states, errors, and data transformation

3. **Service Layer**: API services in `/services` folder
   - Encapsulates all external data interactions
   - Initially uses mock data during development
   - Designed for easy replacement with real API calls later

4. **Mock Data Layer**: Structured mock data in `/data` folder
   - Realistic data that mirrors future database structure
   - Follows the same schema that will be used in production
   - Accessed through service layer, never directly by components

This architecture ensures smooth transition from development to production by allowing the service layer to be swapped from mock implementations to real API calls without changing any UI components.

## 📂 Project Structure & Placeholders

### File Organization

When creating the project structure, follow these guidelines:

```
src/
├── components/            # UI components following atomic design
│   ├── ui/                # Atoms (basic UI components)
│   ├── compound/          # Molecules (combinations of atoms)
│   ├── blocks/            # Organisms (complex UI sections)
│   ├── layout/            # Layout components and templates
│   └── pages/             # Page components
├── hooks/                 # Custom React hooks
├── types/                 # TypeScript type definitions
├── stores/                # Zustand state stores
├── services/              # API and service layer
├── data/                  # Mock data for development
└── utils/                 # Utility functions
```

### Placeholder File Guidelines

When creating placeholder files for the project structure:

1. **Content**: Include ONLY comments (3-5 lines) explaining:
   - File purpose
   - Key functionality
   - Related components/services
   - Expected props/parameters
   - Data relationships

2. **Format**: Use this standard format for all placeholder files:
```javascript
/**
 * [Component/Service/Store Name]
 * 
 * Purpose: [Brief description of what this file does]
 * 
 * Related: [List related files that interact with this one]
 * 
 * [Any additional notes about implementation details]
 */
```

3. **No Implementation**: Do not include any actual code implementation in placeholder files, only comments.

## 📱 Mobile PWA Implementation

### Project Structure

A well-organized file structure supports scalability and maintainability:

```
src/
├── assets/                 # Static assets
├── components/             # UI components
│   ├── ui/                 # Base UI components
│   ├── forms/              # Form components
│   ├── layout/             # Layout components
│   └── shared/             # Shared components
├── lib/                    # Utility functions
│   ├── utils.ts            # General utilities
│   ├── auth.ts             # Authentication utilities
│   └── hooks/              # Custom React hooks
├── store/                  # Zustand state management
├── services/               # API services
├── routes/                 # React Router routes
├── types/                  # TypeScript type definitions
├── styles/                 # Global styles
└── public/                 # Static assets
    ├── manifest.json       # PWA manifest
    └── ...                 # Icons, etc.
```

### Mobile-First PWA Configuration

PWA Manifest (public/manifest.json)

```json
{
  "name": "[PROJECT_NAME]",
  "short_name": "[SHORT_NAME]",
  "description": "A mobile-first progressive web application",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff", // Should match your background color
  "theme_color": "#3b82f6", // Should match your primary color
  "orientation": "portrait",
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
  ]
}
```

Note: Replace [PROJECT_NAME], [SHORT_NAME], and update the colors to match your brand's palette.

### Mobile Bottom Navigation

```jsx
export function BottomNav() {
  const location = useLocation();
  const { user } = useUserStore();
  
  // Dynamic navigation items based on user role
  const navItems = [
    {
      name: "Home",
      href: "/",
      icon: Home,
      active: location.pathname === "/"
    },
    {
      name: "Search",
      href: "/search",
      icon: Search,
      active: location.pathname === "/search"
    },
    {
      name: "Profile",
      href: "/profile",
      icon: User,
      active: location.pathname === "/profile"
    }
  ];
  
  // Add admin section if user has admin role
  if (user?.role === "admin") {
    navItems.push({
      name: "Settings",
      href: "/settings",
      icon: Settings,
      active: location.pathname === "/settings"
    });
  }
  
  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-background border-t border-border h-16 px-2 flex items-center justify-around pb-[env(safe-area-inset-bottom)]">
      {navItems.map(item => (
        <Link
          key={item.href}
          to={item.href}
          className={cn(
            "flex flex-col items-center justify-center min-w-[64px] min-h-[44px] rounded-md p-1",
            item.active
              ? "text-primary"
              : "text-muted-foreground hover:text-foreground"
          )}
        >
          <item.icon className={cn("h-5 w-5", item.active ? "text-primary" : "text-muted-foreground")} />
          <span className="text-xs mt-1">{item.name}</span>
        </Link>
      ))}
    </nav>
  );
}
```

### State Management with Zustand

```jsx
// Create store with persistence
export const useUserStore = create<UserState>()(
  persist(
    (set) => ({
      user: null,
      isAuthenticated: false,
      login: (user) => set({ user, isAuthenticated: true }),
      logout: () => set({ user: null, isAuthenticated: false }),
    }),
    {
      name: 'user-storage',
    }
  )
);

// UI state store (non-persistent)
export const useUIStore = create<UIState>((set) => ({
  isBottomSheetOpen: false,
  activeTab: 'home',
  setBottomSheetOpen: (isOpen) => set({ isBottomSheetOpen: isOpen }),
  setActiveTab: (tab) => set({ activeTab: tab }),
}));
```

### Dynamic Routing Based on User Role

```jsx
// Protected route wrapper
export function ProtectedRoute({ 
  allowedRoles = ['user', 'admin']
}: { 
  allowedRoles?: string[]
}) {
  const { user, isAuthenticated } = useUserStore();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  if (user && !allowedRoles.includes(user.role)) {
    return <Navigate to="/unauthorized" replace />;
  }
  
  return <Outlet />;
}

// Admin route wrapper
export function AdminRoute() {
  return <ProtectedRoute allowedRoles={['admin']} />;
}
```

## 🔄 Maintenance & Evolution

Guidelines for maintaining and evolving the design system over time.

### Version Control

- Semantic Versioning: Follow MAJOR.MINOR.PATCH pattern
- Breaking Changes: Major version bumps with migration guides
- Deprecation Process: Gradual phase-out of old patterns
- Change Documentation: Clear changelogs and migration paths
- Compatibility Layers: When needed for graceful upgrades

### System Extension

- Component Additions: Follow existing patterns and architecture
- Token Extensions: Maintain spacing and sizing ratios
- Variant Expansion: Consistent with existing variants
- Pattern Evolution: Based on user testing and feedback
- Documentation Updates: Keep in sync with implementation

### Quality Monitoring

- Design Drift Detection: Regular audits for consistency
- Accessibility Regression: Automated testing in CI/CD
- Performance Monitoring: Track metrics over time
- User Feedback Collection: Systematic gathering of issues
- Cross-Team Reviews: Regular design system reviews

## 📏 Implementation Guidelines

### CSS Variables

```css
/* styles/globals.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --font-sans: "Inter", system-ui, sans-serif;

    /* Base colors - REPLACE WITH YOUR PROJECT'S COLOR PALETTE */
    --background: 0 0% 100%;
    --foreground: 222 47% 11%;
    --card: 0 0% 100%;
    --card-foreground: 222 47% 11%;
    --popover: 0 0% 100%;
    --popover-foreground: 222 47% 11%;
    --primary: 221 83% 53%;
    --primary-foreground: 210 40% 98%;
    --secondary: 217 91% 60%;
    --secondary-foreground: 210 40% 98%;
    --muted: 210 40% 96%;
    --muted-foreground: 215 16% 47%;
    --accent: 210 40% 96%;
    --accent-foreground: 222 47% 11%;
    --destructive: 0 84% 60%;
    --destructive-foreground: 210 40% 98%;
    --border: 214 32% 91%;
    --input: 214 32% 91%;
    --ring: 221 83% 53%;

    --radius-sm: 0.375rem;
    --radius-md: 0.5rem;
    --radius-lg: 0.75rem;
    
    /* For mobile viewports */
    --vh: 1vh;
  }

  .dark {
    --background: 222 47% 11%;
    --foreground: 210 40% 98%;
    --card: 222 47% 11%;
    --card-foreground: 210 40% 98%;
    --primary: 217 91% 60%;
    --primary-foreground: 210 40% 98%;
    --secondary: 217 91% 60%;
    --secondary-foreground: 210 40% 98%;
    --muted: 217 33% 17%;
    --muted-foreground: 215 20% 65%;
    --accent: 217 33% 17%;
    --accent-foreground: 210 40% 98%;
    --destructive: 0 62% 60%;
    --destructive-foreground: 210 40% 98%;
    --border: 217 33% 17%;
    --input: 217 33% 17%;
    --ring: 224 76% 48%;
  }
}
```

## 🧪 Implementation Checklist

- [ ] Set up project with Vite, React Router, and Tailwind CSS
- [ ] Configure tailwind.config.js with design tokens
- [ ] Create basic component library based on design system
- [ ] Implement dynamic viewport height (dvh) for mobile layouts
- [ ] Set up responsive media queries
- [ ] Create mobile bottom navigation component
- [ ] Implement bottom sheet component
- [ ] Set up one-field-per-step form system
- [ ] Configure Zustand store for state management
- [ ] Create mock data structure for development
- [ ] Implement CRUD service layer
- [ ] Set up dynamic routing based on user roles
- [ ] Configure PWA manifest and service worker
- [ ] Test on actual mobile devices
- [ ] Ensure accessibility compliance
- [ ] Optimize performance for mobile
- [ ] Implement dark mode support
- [ ] Set up CI/CD pipeline
- [ ] Create documentation for the design system