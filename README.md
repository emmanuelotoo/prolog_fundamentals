# Prolog Fundamentals — Exam Prep Course

Based on **Chapter 5: Logic Programming with Prolog** from
*Introduction to Artificial Intelligence* by Wolfgang Ertel (2nd Edition, Springer 2017).

## Prerequisites

- **SWI-Prolog** installed ([https://www.swi-prolog.org](https://www.swi-prolog.org))
- Load any lesson: `?- [lesson_01_facts_rules].`

## Lessons

| File | Topic | Ertel Section |
|------|-------|---------------|
| `lesson_01_facts_rules.pl` | Horn clauses, facts, rules, queries, unification | 5.2 |
| `lesson_02_family.pl` | Family relationships, search trees, backtracking | 5.2 |
| `lesson_03_control.pl` | Cut, fail, negation as failure | 5.3 |
| `lesson_04_lists.pl` | Lists, append, naive reverse, accumulator reverse | 5.4 |
| `lesson_05_self_modifying.pl` | Assert, retract, memoization (Fibonacci) | 5.5 |
| `lesson_06_planning.pl` | Farmer-wolf-goat-cabbage planning problem | 5.6 |
| `lesson_07_clp.pl` | Constraint Logic Programming with clpfd | 5.7 |
| `lesson_08_exercises.pl` | Combined exam-style practice problems | 5.2-5.9 |

## How to Use

1. Work through the lessons in order (concepts build progressively).
2. Read the comment blocks — they serve as study notes.
3. Look for `% EXAM:` markers — these highlight high-probability exam topics.
4. Try the exercise skeletons before scrolling to the solutions.
5. Load each file in SWI-Prolog and experiment with the example queries.

## Exam Tips

- Practice **drawing search trees** by hand (lesson 02).
- Know the **cut semantics** — what exactly gets pruned (lesson 03).
- Memorize the **complexity of naive reverse vs accumulator reverse** (lesson 04).
- Understand **declarative vs procedural semantics** (lesson 02).
- Be able to **formulate CLP constraints** from word problems (lesson 07).
