class OrganisationsController < ApplicationController
  def index
    @agents = current_organisation.agents
  end
end
