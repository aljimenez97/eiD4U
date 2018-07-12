require "prawn"
class StudentApplicationFormController < ApplicationController
	before_action :authenticate_user!
	before_action :validate_admin?, only: [:review_step]

	include PdfHelper
	def sap_page
		@sap = current_user.student_application_form
		render "student_application_form/student_application_form"
	end

	def review_step
		user = User.find(params[:user])
		if user.role == "admin"
			redirect_back fallback_location: root_path
		else
			render "student_application_form/review_student_application_form"
		end
	end

	def change_step
		if !params[:step].blank?
			@sap = current_user.student_application_form
			@sap.step = params[:step].to_i
			@sap.save!
		end
		render "student_application_form/student_application_form"
	end

	def save
		@sap = current_user.student_application_form
		step = params[:step].to_i
		step = nil if (step.to_s != params[:step])

		if !params[:student_application_form][:languages].blank?
			@sap.languages.destroy_all
			languages = params[:student_application_form][:languages]
			languages.each do |language|
				lan = Language.new
				lan.name = language[:name]
				lan.currently_studying = language[:currently_studying]
				lan.able_follow_lectures = language[:able_follow_lectures]
				lan.able_follow_lectures_extra_preparation = language[:able_follow_lectures_extra_preparation]
				@sap.languages << lan
				lan.save!
			end
		end

		if !params[:student_application_form][:work_experiences].blank?
			@sap.work_experiences.destroy_all
			wexes = params[:student_application_form][:work_experiences]
			wexes.each do |wex|
				we = WorkExperience.new
				we.type = wex[:type]
				we.country = wex[:country]
				we.firm_organisation = wex[:firm_organisation]
				we.from = wex[:from]
				we.to = wex[:to]
				@sap.work_experiences << we
				we.save!
			end
		end
		

		@sap.assign_attributes(params.require(:student_application_form).permit(
				:inst_sending_name, 
				:inst_adress,
				:school_family_dpt,
		  		:erasmus_code,
		  		:dept_coordinator,
		      	:contact_person,
		  		:inst_telephone,
		  		:inst_email,
		  		:academic_year,
		  		:programme,
		  		:field_of_study,
		  		:project_work,
		  		:under_grad_courses,
		  		:graduate_courses,
		  		:reasons_abroad,
		  		:mother_tongue,
		  		:language_instruction,
		  		:current_diploma_degree,
		  		:year_attended,
		  		:specialization_area,
		  		:already_study_abroad,
		  		:where_study_abroad,
		  		:where_institution_abroad,
		  		:no_work_experience
			))


		@sap.save!
		# render "student_application_form/student_application_form"
		if !step.blank? and step.between?(1,6)
			redirect_to "#{student_application_form_path}/#{step}"
		else
			redirect_to user_dashboard_path
		end
	end


	def generate_pdf
		unless current_user.role === 'admin' 
			send_data create_pdf(current_user), :filename => "application_form.pdf", :type => "application/pdf"
		else
			if User.exists?(params[:user])
				user = User.find(params[:user])
				send_data create_pdf(user), :filename => "application_form.pdf", :type => "application/pdf"
			else
				redirect_to admin_dashboard_path
			end
		end
	end


	private

	def languages_params
		params.require(:languages).permit(
					:languages,
					:name,
		  			:currently_studying,
		  			:able_follow_lectures,
		  			:able_follow_lectures_extra_preparation)
	end

	def toNumeral(number)
		numeralhash = {1=>"first", 2=>"second", 3=>"third", 4=>"fourth",5=>"fifth",6=>"sixth",7=>"seventh"}
		if numeralhash.has_key?number
			numeralhash[number]
		else
			"first"
		end
	end




end
