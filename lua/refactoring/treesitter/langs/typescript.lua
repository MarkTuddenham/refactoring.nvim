local TreeSitter = require("refactoring.treesitter.treesitter")
local Nodes = require("refactoring.treesitter.nodes")
local FieldNode = Nodes.FieldNode
local StringNode = Nodes.StringNode
local InlineNode = Nodes.InlineNode

local Typescript = {}

function Typescript.new(bufnr, ft)
    local ts = TreeSitter:new({
        filetype = ft,
        bufnr = bufnr,
        require_param_types = true,
        scope_names = {
            program = "program",
            function_declaration = "function",
            method_definition = "function",
            arrow_function = "function",
            class_declaration = "class",
        },
        block_scope = {
            statement_block = true,
        },
        variable_scope = {
            lexical_declaration = true,
        },
        indent_scopes = {
            program = true,
            function_declaration = true,
            method_definition = true,
            arrow_function = true,
            class_declaration = true,
            if_statement = true,
            for_statement = true,
            for_in_statement = true,
            while_statement = true,
            do_statement = true,
        },
        valid_class_nodes = {
            class_declaration = true,
            abstract_class_declaration = true,
        },
        local_var_names = {
            InlineNode(
                "(lexical_declaration (variable_declarator name: (_) @tmp_capture))"
            ),
        },
        function_args = {
            InlineNode(
                "((formal_parameters (required_parameter (identifier) @tmp_capture)))"
            ),
            InlineNode(
                "((formal_parameters (optional_parameter (identifier) @tmp_capture)))"
            ),
            InlineNode("(for_in_statement left: (identifier) @tmp_capture)"),
        },
        local_var_values = {
            InlineNode(
                "(lexical_declaration (variable_declarator value: (_) @tmp_capture))"
            ),
        },
        local_declarations = {
            InlineNode("(lexical_declaration) @definition.local_declarator"),
        },
        debug_paths = {
            function_declaration = FieldNode("name"),
            method_definition = FieldNode("name"),
            class_declaration = FieldNode("name"),
            abstract_class_declaration = FieldNode("name"),
            arrow_function = function(node)
                return FieldNode("name")(node:parent(), "(anon)")
            end,
            if_statement = StringNode("if"),
            for_statement = StringNode("for"),
            for_in_statement = StringNode("for_in"),
            while_statement = StringNode("while"),
            do_statement = StringNode("do"),
        },
        statements = {
            InlineNode("(expression_statement) @tmp_capture"),
            InlineNode("(return_statement) @tmp_capture"),
            InlineNode("(if_statement) @tmp_capture"),
            InlineNode("(for_statement) @tmp_capture"),
            InlineNode("(for_in_statement) @tmp_capture"),
            InlineNode("(do_statement) @tmp_capture"),
            InlineNode("(while_statement) @tmp_capture"),
            InlineNode("(lexical_declaration) @tmp_capture"),
        },
        function_scopes = {
            method_definition = true,
            function_declaration = true,
            arrow_function = true,
        },
        parameter_list = {
            InlineNode("(formal_parameters (required_parameter) @capture)"),
        },
    }, bufnr)

    -- overriding function
    function ts.get_arg_type_key(arg)
        return arg .. ":"
    end

    return ts
end

return Typescript
