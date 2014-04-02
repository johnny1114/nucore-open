class SurveyResponse

  attr_reader :params


  def initialize(params)
    @params = params
  end


  def save!
    od = OrderDetail.find params[:receiver_id]
    external_service = ExternalService.find params[:external_service_id]
    receiver = ExternalServiceReceiver.where(receiver_id: od.id, external_service_id: external_service.id).first
    json = response_data

    ExternalServiceReceiver.transaction do
      if receiver
        receiver.update_attribute :response_data, json unless receiver.response_data == json
      else
        receiver = ExternalServiceReceiver.create(
          receiver: od,
          external_service: external_service,
          response_data: json
        )
      end

      od.merge!
    end

    receiver
  end


  def response_data
    show_url = params[:survey_url]
    # new survey services (i.e. IMSERC) provide the edit URL
    # old survey services (i.e. Surveyor) have the edit URL inferred
    edit_url = params[:survey_edit_url] || "#{show_url}/take"
    { show_url: show_url, edit_url: edit_url }.to_json
  end

end
