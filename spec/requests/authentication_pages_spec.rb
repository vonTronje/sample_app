require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }
      
    it { should have_h1('Sign in') }
    it { should have_title('Sign in') }
  end

  describe "signin" do
  	before { visit signin_path }

  	describe "with invalid infomation" do
  	  before { click_button "Sign in" }

  	  it { should have_title('Sign in') }
  	  it { should have_error_message('Invalid') }
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }

  	  describe "after visiting another page" do
  	  	before { click_link "Home" }
  	  	it { should_not have_error_message('Invalid')  }
  	  end
  	end

  	describe "with valid information" do
  	  let(:user) { FactoryGirl.create(:user) }
  	  before { sign_in user }

  	  it { should have_title(user.name) }

      it { should have_link('Users', href: users_path) }
  	  it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
  	  it { should have_link('Sign out', href: signout_path) }
      
  	  it { should_not have_link('Sign in', href: signin_path) }

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
  	end
  end

  describe "authorization" do

    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "they should not access 'new' action" do
        before { get signup_path }
        specify { response.should redirect_to(root_path) }
      end

      describe "they should not access 'create' action" do
        before { post signup_path }
        specify {response.should redirect_to(root_path)}
      end
    end

    describe "for non-signed_in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "when attempting to visit a protected page" do
        before { visit edit_user_path(user) }

        describe "after signing in" do
          before { sign_in(user) }

          it "should render the desired protected page" do
            page.should have_title('Edit user')
          end

          describe "and logging out" do
            before { delete signout_path }

            describe "and logging in again" do
              before { sign_in(user) }

              it "should be the profile(default) page" do
                page.should have_title(user.name)
                page.should have_h1(user.name)
              end
            end
          end
        end

        describe "in the Microposts controller" do

          describe "submitting to the create action" do
            before { post microposts_path }
            specify { response.should redirect_to(signin_path) }
          end

          describe "submitting to the destroy action" do
            before { delete micropost_path(FactoryGirl.create(:micropost)) }
            specify { response.should redirect_to(signin_path) }
          end
        end         
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify {response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end
    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title(full_title('Edit user')) }
      end

      describe "submitting a PUT request to the Users#update action" do
        before {put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end
  end
end
