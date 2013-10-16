class HpsBioindexApp 

  helpers do

    def name_details(name)
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
      else
        eol_data = nil
        outlink = Outlink.new(url: 'http://google.com/search?' +
                              "q=%s" % name.name)
      end
      [outlink, eol_data]
    end

  end
end
