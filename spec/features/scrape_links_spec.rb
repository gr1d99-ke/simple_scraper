# frozen_string_literal: true

require 'rails_helper'

feature 'scraping links process' do
  let(:form_xpath) { ".//form[@name='links-scraper-form']" }
  let(:url) { 'https://example.com/links.html' }
  let(:body) { File.read("#{scraper_test_files_path}links.html") }

  before do
    visit(root_path)
    click_on("Get Started")
  end

  scenario 'user sees link scraper form' do
    expect(page).to have_selector(:xpath, form_xpath)
    within(:xpath, form_xpath) do
      expect(page).to have_selector(:xpath, ".//input[@name='uri[email]']")
      expect(page).to have_selector(:xpath, ".//input[@name='uri[host]']")
      expect(page).to have_selector(:xpath, ".//select[@name='uri[depth]']")
      expect(page).to have_selector(
        :xpath, ".//input[@value='fetch me all links']"
      )
    end
  end

  scenario 'user enters details to the scraper form' do
    email = 'test@example.com'
    expect(page).to have_selector(:xpath, form_xpath)

    within(:xpath, form_xpath) do
      expect(find_field('Depth').value).to eq("0")

      fill_in('Email', with: email)
      fill_in('Host', with: url)
      select("1", from: "Depth")

      expect(find_field('Email').value).to eq(email)
      expect(find_field('Host').value).to eq(url)
      expect(find_field('Depth').value).to eq("1")
    end
  end

  scenario 'user submits links scraping request' do
    perform_enqueued_jobs do
      stub_custom_request(url: url, body: body)
      stub_custom_request(url: /https:\/\/example.com\//, body: body)

      within(:xpath, form_xpath) do
        fill_in('Email', with: 'test@example.com')
        fill_in('Host', with: url)
        select("1", from: "Depth")
        click_on('fetch me all links')
      end

      expect(page).to have_content('We will notify and send you all links via the email you provided shortly')
    end
  end

  scenario "user submits a url that is not valid" do
    stub_custom_request(url: url, body: body)

    within(:xpath, form_xpath) do
      fill_in('Email', with: 'test@example.com')
      fill_in('Host', with: "1")
      select("1", from: "Depth")
      click_on('fetch me all links')
    end

    expect(page).to have_content("Host is not a valid url")
  end
end
