class HpsBioindexApp 

  helpers do

    def name_details(name)
      eol_data = eol_url = nil
      outlink = Outlink.select([:url, 'outlinks.id'] ).
        joins('join resolved_name_strings
          on resolved_name_strings.id = resolved_name_string_id').
        joins('join canonical_forms
          on canonical_forms.id =
            resolved_name_strings.canonical_form_id').
        where("canonical_forms.id = %s" % name.id).first
      if outlink
        eol_data = EolData.includes(:eol_data_synonyms, 
                                     :eol_data_vernaculars).
                                     where(outlink_id: outlink.id).first
        eol_url = outlink.url
      end
      google_url = 'http://google.com/search?' + "q=%s" % name.name
      [eol_url, google_url, eol_data]
    end

    def get_items_by_decade
      decades = {}
      res = Item.connection.select_rows("
        select distinct item_id, substring(value, 1, 4) as date 
        from metadata 
        where qualifier = 'createdstandard' 
        having  date > 1800  
        order by date")
      current_decade = nil
      res.each do |row|
        year = row[1].to_i
        item = row[0]
        if !current_decade || year - current_decade >= 10
          current_decade = (year.to_s[0..2] + '0').to_i
          decades[current_decade] = [item]
        else
          decades[current_decade] << item
        end
      end
      decades
    end

    def get_names_by_decade(items_by_decades)
      res = {} 
      items_by_decades.each do |key, value|
        res[key] = []
        require 'ruby-debug'; debugger
        puts ''
      end
    end

  end

end

