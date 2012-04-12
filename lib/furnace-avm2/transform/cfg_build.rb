module Furnace::AVM2
  module Transform
    class CFGBuild
      include AST::Visitor

      def transform(ast)
        @ast = ast

        @jumps = Set.new

        visit @ast

        @cfg = CFG::Graph.new

        @pending_label = nil
        @pending_queue = []

        @ast.children.each_with_index do |node, index|
          @pending_label ||= node.metadata[:label]
          @pending_queue << node if ![:nop, :jump].include? node.type

          next_node  = @ast.children[index + 1]
          next_label = next_node.metadata[:label] if next_node

          case node.type
          when :label
            @jumps.add node.children.first
            node.update :nop

          when :return_value, :return_void
            cutoff(nil, [nil])

          when :jump
            @jumps.add(node.children[0])
            cutoff(nil, [ node.children.delete_at(0) ])

          when :jump_if
            @jumps.add(node.children[1])
            cutoff(node, [ node.children.delete_at(1), next_label ])

          when :lookup_switch
            jumps_to = [ node.children[0] ] + node.children[1]
            @jumps.merge(jumps_to)
            cutoff(node, jumps_to)

          else
            if @jumps.include? next_label
              cutoff(nil, [next_label])
            end
          end
        end

        exit_node = CFG::Node.new(@cfg)
        @cfg.nodes.add exit_node
        @cfg.exit = exit_node

        @cfg.eliminate_unreachable!
        @cfg.merge_redundant!

        @cfg
      end

      # propagate labels
      def on_any(node)
        return if node == @ast

        label = nil

        node.children.each do |child|
          if child.is_a?(AST::Node) && child.metadata[:label]
            if label.nil? || child.metadata[:label] < label
              label = child.metadata[:label]
            end

            child.metadata.delete :label
          end
        end

        node.metadata[:label] = label if label
      end

      def cutoff(cti, targets)
        node = CFG::Node.new(@cfg, @pending_label, @pending_queue, cti, targets)

        if @cfg.nodes.empty?
          @cfg.entry = node
        end

        @cfg.nodes.add node

        @pending_label = nil
        @pending_queue = []
      end
    end
  end
end