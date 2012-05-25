require 'spec_helper'

describe "UserPages" do
  
  subject { page }

  describe "signup page" do
  	before { visit signup_path }

  	it { should have_h1('Sign up') }
  	it { should have_title(full_title('Sign up')) }
  end

  describe "profile page" do
  	let(:user) { FactoryGirl.create(:user) }
  	before { visit user_path(user) }

  	it { should have_h1(user.name) }
  	it { should have_title(user.name) }
  end

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create my account" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end

      describe "after blank submission" do
        before { click_button submit }

        it { should have_title('Sign up') }
        it { should have_content('error') }
        it { should have_content('Password can\'t be blank')}
        it { should have_content('Email can\'t be blank')}
        it { should have_content('Name can\'t be blank')}
        it { should have_content('Email is invalid')}
        it { should have_content('Password confirmation can\'t be blank')}
        it { should have_content('Password is too short (minimum is 6 characters)')}
      end
      # It may be prudent to check single errors, not done yet due to laziness
    end

    describe "with valid information" do
      before { valid_signup }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) {User.find_by_email('user@example.com') }

        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end 
end
