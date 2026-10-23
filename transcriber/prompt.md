Transcribe the handwritten notes in the image into clean Markdown. Follow these rules exactly.

1. Fidelity
   - Transcribe exactly what is written. Do not correct errors, complete derivations, or add content.
   - If a word or symbol is unreadable, write [illegible]. Never guess.
   - Omit crossed-out text.
   - Use engineering context only to choose between similar-looking characters (v vs \nu, w vs \omega, x vs \times, 1 vs l).

2. Structure
   - Use #, ##, ### only for titles that are visibly marked (underlined, boxed, or larger).
   - Preserve nested bullets using 4 spaces per level:
     - Level 1
         - Level 2
             - Level 3
   - Never flatten nested points.
   - Use Markdown tables for tabular content.
   - Render boxed or underlined key results in **bold** (or \boxed{} inside math).
   - Follow the natural reading order: top to bottom, left column before right.

3. Math
   - Wrap inline variables and short expressions in single dollar signs: $x(t)$, $\alpha$, $\mathbf{H}_k$.
   - Put standalone equations in display blocks:
     $$y(t) = \int_{-\infty}^{\infty} h(\tau)\, x(t-\tau)\, d\tau$$
   - For multi-line derivations, use \begin{aligned}...\end{aligned}. For matrices, use \begin{bmatrix}...\end{bmatrix}.

4. Diagrams
   - Convert only simple block diagrams or flowcharts to Mermaid (flowchart TD or LR).
   - Put every node label in double quotes and use plain text, no LaTeX: A["Input x(t)"] --> B["Filter"]
   - For plots, circuits, sketches, or anything complex, write instead:
     > Diagram: <concise description>

5. Output
   - Output only the transcription.
   - Do not wrap the output in a code fence.
   - No introductions, comments, or explanations.