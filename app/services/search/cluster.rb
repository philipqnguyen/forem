module Search
  class Cluster
    SEARCH_CLASSES = [
      Search::ChatChannelMembership,
      Search::Listing,
      Search::FeedContent,
      Search::Tag,
      Search::User,
    ].freeze

    class << self
      def recreate_indexes
        delete_indexes
        setup_indexes
      end

      def setup_indexes
        create_indexes
        update_indexes
        add_aliases
        update_mappings
      end

      def create_indexes
        SEARCH_CLASSES.each do |search_class|
          next if search_class.index_exists?

          search_class.create_index
        end
      end

      def update_indexes
        SEARCH_CLASSES.each(&:update_index)
      end

      def add_aliases
        SEARCH_CLASSES.each(&:add_alias)
      end

      def update_mappings
        SEARCH_CLASSES.each(&:update_mappings)
      end

      def delete_indexes
        return if Rails.env.production?

        SEARCH_CLASSES.each do |search_class|
          next unless Search::Client.indices.exists(index: search_class::INDEX_NAME)

          search_class.delete_index
        end
      end
    end
  end
end
