# Graph Report - workspace  (2026-09-23)

## Corpus Check
- 159 files · ~53,016 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 87 file(s) not represented in the graph (top: .tex 61, (none) 18, .conf 3)

## Summary
- 640 nodes · 1152 edges · 92 communities (35 shown, 57 thin omitted)
- Extraction: 91% EXTRACTED · 9% INFERRED · 0% AMBIGUOUS · INFERRED: 104 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- TikZ Clean Figure
- Dune API Scripts
- Matplotlib Axes Rendering
- TikZ Patch Drawing
- Testing Infrastructure
- Mentat Footer Extension
- TikZ Colorbar Tests
- External Tables Helpers
- Error Bars & Escape Tests
- TikZ Core Init & Image
- Line2D & Markers
- 3D Figure Cleaning
- Clean Figure Pruning
- Clean Figure Data Extraction
- Annotate & Bar Chart Tests
- Color Mapping & Line Drawing
- Arrows & Fancy Box Tests
- Line Cleaning Utilities
- Legend & Content Manager
- Collection Cleaning
- Hatch Patterns
- Corner & Intersection Logic
- Simplification & Pixelation
- Dune Mentat Binary
- File Path Generation
- Quadmesh Tests
- Collection Drawing
- Save Flavors & Preamble
- LSP & Completion Config
- DAP Debugger Config
- Patch Styles Tests
- Treesitter Config
- Pandas DataFrame Tests
- Bar Chart Tests
- Bar Chart Errorbars Tests
- Boxplot Tests
- Subplots Tests
- Setup Scripts
- Dune CLI Binary
- Dune Ghola Binary
- Mason LSP Config
- Conda & OCR Scripts
- Telescope Plugin
- Axvline Tests
- Basic Sin Tests
- Context Tests
- Contourf Tests
- Dual Axis Tests
- Errorband Tests
- Fancy Colorbar Tests
- Heat Map Tests
- Histogram Tests
- Horizontal Alignment Tests
- Legend Labels Tests
- Legend Line Scatter Tests
- Legends Tests
- Legends2 Tests
- Line Collection Tests
- Line Color Marker Tests
- Log Plot Tests
- Marker Tests
- Noise Tests
- Noise2 Tests
- Scatter Tests
- Scatter Colors Tests
- Share Axis Tests
- Subplot 4x4 Tests
- Text Overlay Tests
- Tick Positions Tests
- Viridis Tests
- Dune Spice Binary
- Git Pre-push Hook
- Neovim Init & Clipboard
- Test Tree Printers
- Docker Setup
- TikZplotlib Package Root

## God Nodes (most connected - your core abstractions)
1. `assert_equality()` - 121 edges
2. `clean_figure()` - 32 edges
3. `get_tikz_code()` - 26 edges
4. `Test_plottypes` - 17 edges
5. `_cleanline()` - 13 edges
6. `_recurse()` - 13 edges
7. `Axes` - 11 edges
8. `_clean_collections()` - 11 edges
9. `draw_line2d()` - 11 edges
10. `_get_visual_limits()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `test_memory()` --calls--> `clean_figure()`  [INFERRED]
  python/packages/tikzplotlib/tests/test_cleanfigure.py → python/packages/tikzplotlib/src/tikzplotlib/_cleanfigure.py
- `_recurse()` --calls--> `Axes`  [EXTRACTED]
  python/packages/tikzplotlib/src/tikzplotlib/_save.py → python/packages/tikzplotlib/src/tikzplotlib/_axes.py
- `draw_pathcollection()` --calls--> `_mpl_cmap2pgf_cmap()`  [EXTRACTED]
  python/packages/tikzplotlib/src/tikzplotlib/_path.py → python/packages/tikzplotlib/src/tikzplotlib/_axes.py
- `draw_legend()` --calls--> `mpl_color2xcolor()`  [EXTRACTED]
  python/packages/tikzplotlib/src/tikzplotlib/_legend.py → python/packages/tikzplotlib/src/tikzplotlib/_color.py
- `_bbox()` --calls--> `mpl_color2xcolor()`  [EXTRACTED]
  python/packages/tikzplotlib/src/tikzplotlib/_text.py → python/packages/tikzplotlib/src/tikzplotlib/_color.py

## Import Cycles
- None detected.

## Communities (92 total, 57 thin omitted)

### Community 0 - "TikZ Clean Figure"
Cohesion: 0.09
Nodes (14): clean_figure(), Cleans figure as a preparation for tikz export. This will minimize the number…, get_tikz_code(), Main function. Here, the recursion into the image starts and the contents are…, Testing plot types found here…, test high-level usage for simple example. Test is successful if generated tikz…, test high-level usage for simple example. Test is successful if generated tikz…, test high-level usage for simple example. Test is successful if generated tikz… (+6 more)

### Community 1 - "Dune API Scripts"
Cohesion: 0.07
Nodes (37): base64, generate_enhanced_config(), get_api_key(), Extracts the API key from the ../.env, json, os, parametrize, Popen (+29 more)

### Community 2 - "Matplotlib Axes Rendering"
Cohesion: 0.09
Nodes (25): matplotlib_backends_backend_pgf, Axes, _common_texification(), _find_associated_colorbar(), _gcd(), _gcd_array(), _get_tick_position(), _get_ticks() (+17 more)

### Community 3 - "TikZ Patch Drawing"
Cohesion: 0.11
Nodes (27): _draw_circle(), _draw_ellipse(), _draw_fancy_arrow(), draw_patch(), draw_patchcollection(), _draw_polygon(), _draw_rectangle(), _is_in_legend() (+19 more)

### Community 4 - "Testing Infrastructure"
Cohesion: 0.09
Nodes (19): argparse, configparser, importlib_util, pathlib, pytest, plot(), Hatch demo code from…, test() (+11 more)

### Community 5 - "Mentat Footer Extension"
Cohesion: 0.12
Nodes (23): colorRgb(), colorThinkingLabel(), CONTEXT_COLOR_STOPS, EFFORT_COLOR_STOPS, formatContextWindow(), formatDirectory(), getCurrentDirectory(), getProviderColor() (+15 more)

### Community 6 - "TikZ Colorbar Tests"
Cohesion: 0.11
Nodes (17): allow_rasterization, datetime, matplotlib, plot(), test(), plot(), Custom collection test This tests plots a subclass of Collection, which…, A gutted version of matplotlib.collections.EllipseCollection that lets us pass… (+9 more)

### Community 7 - "External Tables Helpers"
Cohesion: 0.15
Nodes (16): assert_equality(), compare_mpl_tex(), _compile(), _unidiff_output(), plot(), test(), plot(), test() (+8 more)

### Community 8 - "Error Bars & Escape Tests"
Cohesion: 0.14
Nodes (11): matplotlib_pyplot, plot(), test(), plot(), test(), plot(), test(), plot() (+3 more)

### Community 9 - "TikZ Core Init & Image"
Cohesion: 0.15
Nodes (12): enum, pil, Script to convert Matplotlib generated figures into TikZ/PGFPlots figures., _get_color_definitions(), _print_pgfplot_libs_message(), Path, Same as `get_tikz_code()`, but actually saves the code to a file. :param…, Prepends each line in string with the LaTeX comment key, '%'. (+4 more)

### Community 10 - "Line2D & Markers"
Cohesion: 0.22
Nodes (13): matplotlib_dates, matplotlib_markers, matplotlib_transforms, _table(), _mpl_marker2pgfp_marker(), Translates a marker style of matplotlib to the corresponding style in PGFPlots., draw_pathcollection(), Returns PGFPlots code for a number of patch objects. (+5 more)

### Community 11 - "3D Figure Cleaning"
Cohesion: 0.16
Nodes (16): mpl_toolkits, _axIs3D(), _axIsXLog(), _axIsYLog(), _axIsZLog(), _corners3D(), _get_projection_matrix(), _get_visual_limits() (+8 more)

### Community 12 - "Clean Figure Pruning"
Cohesion: 0.16
Nodes (16): _diff(), _elements(), _insert_data(), _isempty(), _isInBox(), _move_points_closer(), _prune_outside_box(), modification of np.diff(x, *args, **kwargs). - If x is empty, return… (+8 more)

### Community 13 - "Clean Figure Data Extraction"
Cohesion: 0.17
Nodes (16): _get_visual_data(), _limit_precision(), Limit the precision of the given data. If alpha is 0 or negative do nothing.…, Replaces data at id_replace with NaNs. :param data: array of x and y data with…, remove data at id_remove :param data: array of x and y data with shape [N, 2]…, data --> xData, yData, xData, yData --> data, data --> xData, yData, zData (+8 more)

### Community 14 - "Annotate & Bar Chart Tests"
Cohesion: 0.19
Nodes (10): numpy, plot(), test(), plot(), Bar Chart Legend test This tests plots a simple bar chart. Bar charts are…, test(), plot(), test() (+2 more)

### Community 15 - "Color Mapping & Line Drawing"
Cohesion: 0.21
Nodes (12): _get_closest_colour_name(), mpl_color2xcolor(), Translates a matplotlib color specification into a proper LaTeX xcolor., draw_line2d(), _marker(), Returns the PGFPlots code for an Line2D environment., get_draw_options(), mpl_linestyle2pgfplots_linestyle() (+4 more)

### Community 16 - "Arrows & Fancy Box Tests"
Cohesion: 0.30
Nodes (9): matplotlib_patches, plot(), box1(), box2(), box3(), box4(), draw_bbox(), plot() (+1 more)

### Community 17 - "Line Cleaning Utilities"
Cohesion: 0.20
Nodes (11): _cleanline(), _get_line_data(), _isStep(), _line_has_lines(), _lineIs3D(), Clean a 2D or 3D Line plot figure. :param fighandle: matplotlib figure object…, Check if plot is a step plot. :param linehandle: matplotlib line handle object…, Check if given line object is a 3D plot. :param linehandle: matplotlib… (+3 more)

### Community 18 - "Legend & Content Manager"
Cohesion: 0.20
Nodes (7): draw_legend(), _get_location_from_best(), _ContentManager, Basic Content Manager for tikzplotlib This manager uses a dictionary to map…, Extends with a list and a z-order, Iterates over all children of the current object, gathers the contents…, _recurse()

### Community 19 - "Collection Cleaning"
Cohesion: 0.22
Nodes (9): _clean_collections(), _clean_containers(), _collectionIs3D(), _get_collection_data(), Recursively visit child objects and clean them up. :param obj: object :param…, Containers are not children of axes. They need to be visited separately. :param…, Clean a 2D or 3D collection, i.e. scatter plot. :param fighandle: matplotlib…, _recursive_cleanfigure() (+1 more)

### Community 20 - "Hatch Patterns"
Cohesion: 0.25
Nodes (8): add_custom_pattern(), _mpl_hatch2pgfp_pattern(), r""" Map matplotlib hatches to tikz patterns For matplotlib hatches, see:…, The patterns of tikzpgf are quite simple, and cannot be customized but for the…, Warn about the shortcomings of patterns, r""" Translates a hatch from matplotlib to the corresponding pattern in…, __validate_hatch(), warnings

### Community 21 - "Corner & Intersection Logic"
Cohesion: 0.25
Nodes (8): _corners2D(), _cross_lines(), Given a bounding box {x,y}Lim, determine whether the line between all pairs of…, Determine the corners of the axes as defined by xLim and yLim :param xLim: x…, Checks whether the segments X1--X2 and X3--X4 intersect. :param X1: X1 :type…, Checks whether the segments X1--X2 and X3--X4 intersect. See…, _segment_visible(), _segments_intersect()

### Community 22 - "Simplification & Pixelation"
Cohesion: 0.25
Nodes (8): _get_width_height_in_pixels(), _opheim_simplify(), _pixelate(), Reduce the number of data points in the line 'handle'. Applies a path-…, Rough reduction of data points at a multiple of the target resolution. The…, Target resolution as ppi / dpi. Return width and height in pixels :param…, Opheim path simplification algorithm. Given a path of vertices V and a…, _simplify_line()

### Community 23 - "Dune Mentat Binary"
Cohesion: 0.33
Nodes (4): dune-mentat script, PYTHON_VERSION, SANDBOX_NAME, TARGET_PROJECT

### Community 24 - "File Path Generation"
Cohesion: 0.40
Nodes (5): _gen_filepath(), new_filepath(), Returns an available filepath. :param file_kind: Name under which numbering is…, draw_image(), Returns the PGFPlots code for an image environment.

### Community 25 - "Quadmesh Tests"
Cohesion: 0.53
Nodes (5): plot(), F(), u(), v(), test()

### Community 26 - "Collection Drawing"
Cohesion: 0.40
Nodes (5): draw_linecollection(), Returns Pgfplots code for a number of patch objects., draw_quadmesh(), Returns the PGFPlots code for an graphics environment holding a rendering of…, _draw_collection()

### Community 29 - "DAP Debugger Config"
Cohesion: 0.50
Nodes (3): dap_python, dapui, nvim_dap_virtual_text

### Community 30 - "Patch Styles Tests"
Cohesion: 0.67
Nodes (3): matplotlib_collections, plot(), test()

### Community 31 - "Treesitter Config"
Cohesion: 0.50
Nodes (3): nvim_treesitter_configs, nvim_treesitter_parsers, treesitter_context

### Community 32 - "Pandas DataFrame Tests"
Cohesion: 0.67
Nodes (3): pandas, plot(), test()

### Community 33 - "Bar Chart Tests"
Cohesion: 0.67
Nodes (3): plot(), Bar Chart test This tests plots a simple bar chart. Bar charts are plotted as…, test()

### Community 34 - "Bar Chart Errorbars Tests"
Cohesion: 0.67
Nodes (3): plot(), Bar Chart With Errorbar test This tests plots a bar chart with error bars. The…, test()

### Community 35 - "Boxplot Tests"
Cohesion: 0.67
Nodes (3): plot(), Box Plot test This test plots a box plot with three data series. The causes an…, test()

### Community 37 - "Setup Scripts"
Cohesion: 0.67
Nodes (3): backup_if_exists(), PATH, setup_full.sh script

## Knowledge Gaps
- **11 isolated node(s):** `ThinkingLevel`, `RgbColor`, `ModelWithThinking`, `THINKING_LEVELS`, `EFFORT_COLOR_STOPS` (+6 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 200 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **57 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `assert_equality()` connect `External Tables Helpers` to `Testing Infrastructure`, `TikZ Colorbar Tests`, `Error Bars & Escape Tests`, `Annotate & Bar Chart Tests`, `Arrows & Fancy Box Tests`, `Quadmesh Tests`, `Patch Styles Tests`, `Pandas DataFrame Tests`, `Bar Chart Tests`, `Bar Chart Errorbars Tests`, `Boxplot Tests`, `Subplots Tests`, `Axvline Tests`, `Basic Sin Tests`, `Context Tests`, `Contourf Tests`, `Dual Axis Tests`, `Errorband Tests`, `Fancy Colorbar Tests`, `Heat Map Tests`, `Histogram Tests`, `Horizontal Alignment Tests`, `Legend Labels Tests`, `Legend Line Scatter Tests`, `Legends Tests`, `Legends2 Tests`, `Line Collection Tests`, `Line Color Marker Tests`, `Log Plot Tests`, `Marker Tests`, `Noise Tests`, `Noise2 Tests`, `Scatter Tests`, `Scatter Colors Tests`, `Share Axis Tests`, `Subplot 4x4 Tests`, `Text Overlay Tests`, `Tick Positions Tests`, `Viridis Tests`?**
  _High betweenness centrality (0.252) - this node is a cross-community bridge._
- **Why does `clean_figure()` connect `TikZ Clean Figure` to `Collection Cleaning`, `TikZ Core Init & Image`, `3D Figure Cleaning`?**
  _High betweenness centrality (0.053) - this node is a cross-community bridge._
- **Why does `get_tikz_code()` connect `TikZ Clean Figure` to `TikZ Core Init & Image`, `Legend & Content Manager`?**
  _High betweenness centrality (0.036) - this node is a cross-community bridge._
- **Are the 28 inferred relationships involving `clean_figure()` (e.g. with `.test_line_markers()` and `.test_line_no_markers()`) actually correct?**
  _`clean_figure()` has 28 INFERRED edges - model-reasoned connections that need verification._
- **Are the 17 inferred relationships involving `get_tikz_code()` (e.g. with `.test_line_markers()` and `.test_line_no_markers()`) actually correct?**
  _`get_tikz_code()` has 17 INFERRED edges - model-reasoned connections that need verification._
- **What connects `ThinkingLevel`, `RgbColor`, `ModelWithThinking` to the rest of the system?**
  _11 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `TikZ Clean Figure` be split into smaller, more focused modules?**
  _Cohesion score 0.09090909090909091 - nodes in this community are weakly interconnected._